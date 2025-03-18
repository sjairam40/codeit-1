#!/usr/bin/env python3
import logging

import boto3
import sys
from botocore.exceptions import ClientError

import webutil
import duo
from getpass import getpass

import keyring

from config import awsconfig
from config.appconfig import get_config, get_mapped_cred_name
from connstate import ConnState
from exception import PinLoginException

from typing import List


def get_password(username: str) -> str:
    password_method = get_config().password_method
    password = ""
    if password_method == "keychain":
        password = keyring.get_password("harvard-key", username)
        if password is None:
            print(f"WARNING: Could not find a password in your keychain for harvard-key/{username}")
    elif password_method is not None:
        raise Exception("Password Method value not valid. Currently only 'keychain' is supported.")

    if password is None or password == "":
        password = getpass("Password: ")

    return password


def do_login(conn_state: ConnState):
    # Only for Reverse Engineering
    # conn_state.session.verify=False

    webutil.get_action_token(conn_state)

    username = get_config().username
    if username is None:
        username = input("Username: ")
    else:
        print("Using default username " + username)

    password = get_password(username)

    logging.debug("start: login_to_pin")
    webutil.login_to_pin(conn_state, username, password)
    logging.debug("end: login_to_pin")


def get_duo_opts(conn_state: ConnState):
    logging.debug("start: post_for_duo_prompt")
    duo.post_for_duo_prompt(conn_state)
    logging.debug("end: post_for_duo_prompt")

    logging.debug("start: get_duo_push_options")
    duo.get_duo_push_options(conn_state)
    logging.debug("end: get_duo_push_options")


def execute_duo(conn_state: ConnState):
    auth_method = get_config().auth_method
    device_id = get_config().device_id

    duo.set_duo_push_option(conn_state, auth_method=auth_method, device_id=device_id)

    while conn_state.duo_push_status not in ("allow", "deny"):
        logging.debug("start: request_duo_push")
        duo.request_duo_push(conn_state)
        logging.debug("end: request_duo_push")

        duo.wait_for_duo_push(conn_state)

        if conn_state.duo_push_status == "timeout":
            conn_state.duo_opt = None
            print("")
            print("Duo request timed out. Please select Duo option:")
            for i in range(len(conn_state.duo_opts)):
                print("{}: {} - {}".format(i, conn_state.duo_opts[i]['name'], conn_state.duo_opts[i]['factor']))

            while conn_state.duo_opt is None:
                try:
                    idx = int(input("> "))
                    duo.set_duo_push_option(conn_state, idx=idx)
                except Exception:
                    print("Please make a valid choice")

    print("")
    if conn_state.duo_push_status != "allow":
        print("Login rejected.")
        sys.exit(1)

    logging.debug("==========>DONE WITH DUO - SUCCESSFULLY AUTHENTICATED via 2FA")


def get_entitlements(conn_state: ConnState) -> List[webutil.EntitlementInfo]:
    # AWS Response format:
    # {
    #     'Credentials': {
    #         'AccessKeyId': 'string',
    #         'SecretAccessKey': 'string',
    #         'SessionToken': 'string',
    #         'Expiration': datetime(2015, 1, 1)
    #     },
    #     'AssumedRoleUser': {
    #         'AssumedRoleId': 'string',
    #         'Arn': 'string'
    #     },
    #     'PackedPolicySize': 123
    # }
    entitlements = webutil.login(conn_state)

    # TODO: This should move elsewhere so we don't refresh all logins all the time.  Not sure if this invalidates old
    #  credentials.
    client = boto3.client('sts')
    for entitlement in entitlements:
        timeout = get_config().default_timeout_seconds
        logging.debug(f"=========> ROLE ARN: {entitlement.role_arn}")
        logging.debug(f"=========> Principle ARN: {entitlement.principle_arn}")
        try:
            try:
                response = client.assume_role_with_saml(
                    RoleArn=entitlement.role_arn,
                    PrincipalArn=entitlement.principle_arn,
                    SAMLAssertion=entitlement.saml_assertion,
                    DurationSeconds=timeout
                )
            except ClientError as ce:
                logging.debug(
                    f"Could not assume role {entitlement} with timeout of {timeout}, trying default timeout.  Error: {str(ce)}")
                response = client.assume_role_with_saml(
                    RoleArn=entitlement.role_arn,
                    PrincipalArn=entitlement.principle_arn,
                    SAMLAssertion=entitlement.saml_assertion
                )
            entitlement.credentials = response['Credentials']
        except Exception as error:
            # Log and move on.
            logging.warning(f"There was an error assuming role: {entitlement.role_arn}: {str(error)}")

    return entitlements


def login_all(entitlements: List[webutil.EntitlementInfo]):
    """
    Login to all configured entitlements.
    :param entitlements:
    :return:
    """
    print("Logging in to all configured roles.")
    aws_conf = awsconfig.get_aws_config()
    aws_creds = awsconfig.get_aws_credentials()
    for entitlement in entitlements:
        cred_name = get_mapped_cred_name(entitlement.role_arn)
        if cred_name is None:
            continue
        print("Logging in: " + str(entitlement.role_arn))

        config_section = "profile " + cred_name
        # Need to create both 'config' and 'credentials' entries for the new profile.
        if not aws_conf.has_section(config_section):
            aws_conf.add_section(config_section)
        if not aws_creds.has_section(cred_name):
            aws_creds.add_section(cred_name)

        aws_conf.set(config_section, "region", "us-east-1")
        credentials = entitlement.credentials
        aws_creds.set(cred_name, "aws_access_key_id", credentials['AccessKeyId'])
        aws_creds.set(cred_name, "aws_session_token", credentials['SessionToken'])
        aws_creds.set(cred_name, "aws_secret_access_key", credentials['SecretAccessKey'])

    awsconfig.backup_aws_configs()
    awsconfig.save_aws_credentials(aws_creds)
    awsconfig.save_aws_config(aws_conf)


def login_default(entitlements: List[webutil.EntitlementInfo]):
    """
    Login and set the default credentials for a specific entitlement.
    :param entitlements:
    :return:
    """

    entitlement = None
    if len(get_config().args) > 1:
        # Login to the profile alias that the user gave us
        alias = get_config().args[1]
        print(f"Logging in to profile {alias}")
        if alias in get_config().profile_map.values():
            default_role_arn = ""
            # find the role ARN mapped to this alias.
            for (key, value) in get_config().profile_map.items():
                if value == alias:
                    default_role_arn = key

            # Find the entitlement that has the same ARN.
            for i in range(len(entitlements)):
                if entitlements[i].role_arn == default_role_arn:
                    entitlement = entitlements[i]
            if entitlement is None:
                print(f"Did not find role {default_role_arn} in list.")
        else:
            print(f"No configured role map for {alias}")

    # Either we couldn't find a match for the alias or we did not have one.  Present a list.
    if entitlement is None:
        # List roles
        print("Select default role:")
        for i in range(len(entitlements)):
            print("{}: {}".format(i, entitlements[i].role_arn))

        while entitlement is None:
            try:
                idx = int(input("> "))
                entitlement = entitlements[idx]
            except Exception:
                # Handle the exception
                print('Please make a valid choice.')

    print("Logging in: " + str(entitlement.role_arn))
    aws_conf = awsconfig.get_aws_config()
    aws_creds = awsconfig.get_aws_credentials()

    # Need to create both 'config' and 'credentials' entries for the new profile.
    if not aws_conf.has_section("default"):
        aws_conf.add_section("default")
    if not aws_creds.has_section("default"):
        aws_creds.add_section("default")

    aws_conf.set("default", "region", "us-east-1")
    credentials = entitlement.credentials
    aws_creds.set("default", "aws_access_key_id", credentials['AccessKeyId'])
    aws_creds.set("default", "aws_session_token", credentials['SessionToken'])
    aws_creds.set("default", "aws_secret_access_key", credentials['SecretAccessKey'])

    awsconfig.backup_aws_configs()
    awsconfig.save_aws_credentials(aws_creds)
    awsconfig.save_aws_config(aws_conf)


def switch_default():
    if get_config().args is None:
        print("No role given to switch to.")
        usage()
        return

    new_default = get_config().args[1]
    print("Switching to " + new_default)

    aws_conf = awsconfig.get_aws_config()
    aws_creds = awsconfig.get_aws_credentials()

    conf_section = "profile " + new_default

    if not aws_conf.has_section(conf_section):
        print("No config entry for \"" + str(conf_section) + "\"")
        sys.exit(1)
    if not aws_creds.has_section(new_default):
        print("No creds entry for \"" + str(new_default) + "\"")
        sys.exit(1)
    if not aws_creds.has_section("default"):
        aws_creds.add_section("default")

    aws_creds.set("default", "aws_access_key_id", aws_creds.get(new_default, "aws_access_key_id"))
    aws_creds.set("default", "aws_session_token", aws_creds.get(new_default, "aws_session_token"))
    aws_creds.set("default", "aws_secret_access_key", aws_creds.get(new_default, "aws_secret_access_key"))

    awsconfig.backup_aws_configs()
    awsconfig.save_aws_credentials(aws_creds)


def list_entitlements(entitlements: List[webutil.EntitlementInfo]):
    """
    Print list of roles.
    :param entitlements:
    :return:
    """
    print("Role ARNs available:")
    for entitlement in entitlements:
        print(entitlement.role_arn)


def list_duo_opts(duo_opts: List[dict]):
    """
    Print list of duo options.
    :param duo_opts:
    :return:
    """
    print("Duo options available:")
    for opt in duo_opts:
        print(f"  {opt['name']} - {{ \"auth_method\": \"{opt['factor']}\", \"device_id\": \"{opt['index']}\" }}")


def usage():
    print("{} [-h] [-a] [-l] [list|login|login_all|help|switch]".format(sys.argv[0]))
    print()
    print("\t-v \t Version.")
    print("\t-h \t Help.")
    print("\t-d \t Enable debug output.")
    print(
        "\t-t <secs>\t Set timeout to request credentials to last for (may not be supported if too big - default is 4 hours).")
    print("\t-a \t Login to all configured accounts (when used with 'login' command).")
    print("Commands:")
    print("\tlist\t\tList available role ARNs")
    print("\tlist_duo\tList available Duo options")
    print("\thelp\t\tHelp.")
    print("\tlogin [alias]\tLogin to a role and set your default credentials for that role.")
    print("\tlogin_all\tLogin to all configured profiles.")
    print("\tswitch <role>\tChange default credentials to those of \"role\".")


def version():
    print("1.2.0")


if __name__ == '__main__':
    # conn_state will maintain all the various headers, tokens, etc. used as part of the login process.
    conn_state = ConnState()
    conn_state.session = webutil.create_session()

    if get_config().verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.WARNING)

    cmd = get_config().cmd
    try:
        if get_config().show_version:
            version()
            sys.exit(0)
        if cmd == 'usage' or get_config().usage:
            usage()
            sys.exit(0)
        elif cmd == 'login_all':
            # Login to all configured accounts.  Set default by config.
            do_login(conn_state)
            get_duo_opts(conn_state)
            execute_duo(conn_state)
            entitlements = get_entitlements(conn_state)
            login_all(entitlements)
        elif cmd == 'switch':
            # Switch default
            switch_default()
        elif cmd == 'login':
            # Login and set default account.
            do_login(conn_state)
            get_duo_opts(conn_state)
            execute_duo(conn_state)
            entitlements = get_entitlements(conn_state)
            if get_config().login_all:
                login_all(entitlements)
            login_default(entitlements)
        elif cmd == 'list':
            do_login(conn_state)
            get_duo_opts(conn_state)
            execute_duo(conn_state)
            entitlements = get_entitlements(conn_state)
            list_entitlements(entitlements)
        elif cmd == 'list_duo':
            do_login(conn_state)
            get_duo_opts(conn_state)
            list_duo_opts(conn_state.duo_opts)
        else:
            print("No command given.")
            usage()
    except PinLoginException as e:
        print("Unable to login to PIN (bad password?) - run with '-d' to see response.")
        if get_config().verbose:
            print(e)