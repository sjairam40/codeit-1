#!/usr/bin/env bash
VERSION=2.0
DEBUG="FALSE"
file=sslCheck
# Program: SSL Certificate Check <ssl-cert-check>
#
# Usage:
#  Refer to the usage() sub-routine, or invoke ssl-cert-check
#  with the "-h" option.

# Cleanup temp files if they exist
trap cleanup EXIT INT TERM QUIT

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/ssl/bin:/usr/sfw/bin
export PATH

# Who to page when an expired certificate is detected (cmdline: -e)
ADMIN="root"

# Don't send E-mail by default (cmdline: -a)
ALARM="FALSE"

# Type of certificate (PEM, DER, NET) (cmdline: -t)
CERTTYPE="pem"

# Don't run as a Nagios plugin by default (cmdline: -n)
NAGIOS="FALSE"

# Don't summarize Nagios output by default (cmdline: -N)
NAGIOSSUMMARY="FALSE"

# NULL out the PKCSDBPASSWD variable for later use (cmdline: -k)
PKCSDBPASSWD=""

# If QUIET is set to TRUE, don't print anything on the console (cmdline: -q)
QUIET="FALSE"

# Email sender address for alarm notifications
SENDER=""

# Number of days in the warning threshhold (cmdline: -x)
WARNDAYS=31

#######################################
## Location of system binaries
#######################################

AWK=$(command -v awk)
DATE=$(command -v date)
ECHO=$(command -v echo)
FIND=$(command -v find)
GREP=$(command -v grep)
MKDIR=$(command -v mkdir)
MKTEMP=$(command -v mktemp)
OPENSSL=$(command -v openssl)
PRINTF=$(command -v printf)
RM=$(command -v rm)
SED=$(command -v sed)
TEE=$(command -v tee)
TOUCH=$(command -v touch)
UNAME=$(command -v uname)

# Try to find a mail client
if [ -f /usr/bin/mailx ]; then
    MAIL="/usr/bin/mailx"
    MAILMODE="mailx"
elif [ -f /bin/mail ]; then
    MAIL="/bin/mail"
    MAILMODE="mail"
elif [ -f /usr/bin/mail ]; then
    MAIL="/usr/bin/mail"
    MAILMODE="mail"
elif [ -f /sbin/mail ]; then
    MAIL="/sbin/mail"
    MAILMODE="mail"
elif [ -f /usr/sbin/mail ]; then
    MAIL="/usr/sbin/mail"
    MAILMODE="mail"
elif [ -f /usr/sbin/sendmail ]; then
    MAIL="/usr/sbin/sendmail"
    MAILMODE="sendmail"
else
    MAIL="cantfindit"
    MAILMODE="cantfindit"
fi

## dateTime=`date +%d-%m-%Y-%H-%M-%S`
dateTime=`date +%Y%m%d`
##dir=/Users/sjairam/dgadmin/logs/nmapCheck

# Return code used by nagios. Initialize to 0.
RETCODE=0

# Certificate counters and minimum difference. Initialize to 0.
SUMMARY_VALID=0
SUMMARY_WILL_EXPIRE=0
SUMMARY_EXPIRED=0
SUMMARY_MIN_DIFF=0
SUMMARY_MIN_DATE=
SUMMARY_MIN_HOST=
SUMMARY_MIN_PORT=

# Set the default umask to be somewhat restrictive
umask 077

#####################################################
### Check the expiration status of a certificate file
### Accepts three parameters:
###  $1 -> certificate file to process
###  $2 -> Server name
###  $3 -> Port number of certificate
#####################################################
check_file_status() {

    CERTFILE="${1}"
    HOST="${2}"
    PORT="${3}"

    ### Check to make sure the certificate file exists
    if [ ! -r "${CERTFILE}" ] || [ ! -s "${CERTFILE}" ]; then
        echo "ERROR: The file named ${CERTFILE} is unreadable or doesn't exist"
        echo "ERROR: Please check to make sure the certificate for ${HOST}:${PORT} is valid"
        set_returncode 3
        return
    fi

    ### Grab the expiration date from the X.509 certificate
    if [ "${PKCSDBPASSWD}" != "" ]; then
        # Extract the certificate from the PKCS#12 database, and
        # send the informational message to /dev/null
        "${OPENSSL}" pkcs12 -nokeys -in "${CERTFILE}" \
                   -out "${CERT_TMP}" -clcerts -password pass:"${PKCSDBPASSWD}" 2> /dev/null

        # Extract the expiration date from the certificate
        CERTDATE=$("${OPENSSL}" x509 -in "${CERT_TMP}" -enddate -noout | \
                   "${SED}" 's/notAfter\=//')

        # Extract the issuer from the certificate
        CERTISSUER=$("${OPENSSL}" x509 -in "${CERT_TMP}" -issuer -noout | \
                     "${AWK}" 'BEGIN {RS=", " } $0 ~ /^O =/
                                 { print substr($0,5,17)}')

        ### Grab the common name (CN) from the X.509 certificate
        COMMONNAME=$("${OPENSSL}" x509 -in "${CERT_TMP}" -subject -noout | \
                     "${SED}" -e 's/.*CN = //' | \
                     "${SED}" -e 's/, .*//')

        ### Grab the serial number from the X.509 certificate
        SERIAL=$("${OPENSSL}" x509 -in "${CERT_TMP}" -serial -noout | \
                 "${SED}" -e 's/serial=//')
    else
        # Extract the expiration date from the ceriticate
        CERTDATE=$("${OPENSSL}" x509 -in "${CERTFILE}" -enddate -noout -inform "${CERTTYPE}" | \
                   "${SED}" 's/notAfter\=//')

        # Extract the issuer from the certificate
        CERTISSUER=$("${OPENSSL}" x509 -in "${CERTFILE}" -issuer -noout -inform "${CERTTYPE}" | \
                     "${AWK}" 'BEGIN {RS=", " } $0 ~ /^O =/ { print substr($0,5,17)}')

        ### Grab the common name (CN) from the X.509 certificate
        COMMONNAME=$("${OPENSSL}" x509 -in "${CERTFILE}" -subject -noout -inform "${CERTTYPE}" | \
                     "${SED}" -e 's/.*CN = //' | \
                     "${SED}" -e 's/, .*//')

        ### Grab the serial number from the X.509 certificate
        SERIAL=$("${OPENSSL}" x509 -in "${CERTFILE}" -serial -noout -inform "${CERTTYPE}" | \
                 "${SED}" -e 's/serial=//')
    fi

    ### Split the result into parameters, and pass the relevant pieces to date2julian
    set -- ${CERTDATE}
    MONTH=$(getmonth "${1}")

    # Convert the date to seconds, and get the diff between NOW and the expiration date
    CERTJULIAN=$(date2julian "${MONTH#0}" "${2#0}" "${4}")
    CERTDIFF=$(date_diff "${NOWJULIAN}" "${CERTJULIAN}")

    if [ "${CERTDIFF}" -lt 0 ]; then
        if [ "${ALARM}" = "TRUE" ]; then
            send_mail "${SENDER}" "${ADMIN}" "Certificate for ${HOST} \"(CN: ${COMMONNAME})\" has expired!" \
                "The SSL certificate for ${HOST} \"(CN: ${COMMONNAME})\" has expired!"
        fi

        prints "${HOST}" "${PORT}" "Expired" "${CERTDATE}" "${CERTDIFF}" "${CERTISSUER}" "${COMMONNAME}" "${SERIAL}"
        RETCODE_LOCAL=2

    elif [ "${CERTDIFF}" -lt "${WARNDAYS}" ]; then
        if [ "${ALARM}" = "TRUE" ]; then
            send_mail "${SENDER}" "${ADMIN}" "Certificate for ${HOST} \"(CN: ${COMMONNAME})\" will expire in ${CERTDIFF} days or less" \
                "The SSL certificate for ${HOST} \"(CN: ${COMMONNAME})\" will expire on ${CERTDATE}"
        fi
        prints "${HOST}" "${PORT}" "Expiring" "${CERTDATE}" "${CERTDIFF}" "${CERTISSUER}" "${COMMONNAME}" "${SERIAL}"
        RETCODE_LOCAL=1

    else
        prints "${HOST}" "${PORT}" "Valid" "${CERTDATE}" "${CERTDIFF}" "${CERTISSUER}" "${COMMONNAME}" "${SERIAL}"
        RETCODE_LOCAL=0
    fi

    set_returncode "${RETCODE_LOCAL}"
    MIN_DATE=$(echo "${CERTDATE}" | "${AWK}" '{ print $1, $2, $4 }')
    set_summary "${RETCODE_LOCAL}" "${HOST}" "${PORT}" "${MIN_DATE}" "${CERTDIFF}"
}

##########################################################################
# Purpose: Connect to a server ($1) and port ($2) to see if a certificate
#          has expired
# Arguments:
#   $1 -> Server name
#   $2 -> TCP port to connect to
##########################################################################
check_server_status() {

    PORT="$2"
    case "$PORT" in
        ftp|21)                 TLSFLAG="-starttls ftp";;
        lmtp|24)                TLSFLAG="-starttls lmtp";;
        smtp|25|submission|587) TLSFLAG="-starttls smtp";;
        pop3|110)               TLSFLAG="-starttls pop3";;
        nntp|119)               TLSFLAG="-starttls nntp";;
        irc|194)                TLSFLAG="-starttls irc";;
        imap|143)               TLSFLAG="-starttls imap";;
        ldap|389)               TLSFLAG="-starttls ldap";;
        mysql|3306)             TLSFLAG="-starttls mysql";;
        sieve|4190)             TLSFLAG="-starttls sieve";;
        xmpp|5222)              TLSFLAG="-starttls xmpp";;
        xmpp-server|5269)       TLSFLAG="-starttls xmpp-server";;
        postgres|5432)          TLSFLAG="-starttls postgres";;
        *)                      TLSFLAG="";;
    esac

    if [ "${TLSSERVERNAME}" = "FALSE" ]; then
        OPTIONS="-connect ${1}:${2} $TLSFLAG"
    else
        OPTIONS="-connect ${1}:${2} -servername ${1} $TLSFLAG"
    fi

    ##SANJAY
    if [ ${DEBUG} = "TRUE" ]; then
        echo " ---> Check host " $1   
    fi

    echo "" | "${OPENSSL}" s_client $OPTIONS 2> "${ERROR_TMP}" 1> "${CERT_TMP}"

    #Trap connection errors
    if "${GREP}" -i "Connection refused" "${ERROR_TMP}" > /dev/null; then
        prints "${1}" "${2}" "Connection refused" "Unknown"
        set_returncode 3
    elif "${GREP}" -i "No route to host" "${ERROR_TMP}" > /dev/null; then
        prints "${1}" "${2}" "No route to host" "Unknown"
        set_returncode 3
    elif "${GREP}" -i "gethostbyname failure" "${ERROR_TMP}" > /dev/null; then
        prints "${1}" "${2}" "Cannot resolve domain" "Unknown"
        set_returncode 3
    elif "${GREP}" -i "Operation timed out" "${ERROR_TMP}" > /dev/null; then
        prints "${1}" "${2}" "Operation timed out" "Unknown"
        set_returncode 3
    elif "${GREP}" -i "ssl handshake failure" "${ERROR_TMP}" > /dev/null; then
        prints "${1}" "${2}" "SSL handshake failed" "Unknown"
        set_returncode 3
    elif "${GREP}" -i "connect: Connection timed out" "${ERROR_TMP}" > /dev/null; then
        prints "${1}" "${2}" "Connection timed out" "Unknown"
        set_returncode 3
    elif "${GREP}" -i "Name or service not known" "${ERROR_TMP}" > /dev/null; then
        prints "${1}" "${2}" "Unable to resolve the DNS name ${1}" "Unknown"
        set_returncode 3
    else
        check_file_status "${CERT_TMP}" "${1}" "${2}"
    fi
}

#####################################################
# Purpose: Remove temporary files if the script doesn't
#          exit() cleanly
#####################################################
cleanup() {
    if [ -f "${CERT_TMP}" ]; then
        rm -f "${CERT_TMP}"
    fi

    if [ -f "${ERROR_TMP}" ]; then
     rm -f "${ERROR_TMP}"
    fi
}

#############################################################################
# Purpose: Calculate the number of seconds between two dates
# Arguments:
#   $1 -> Date #1
#   $2 -> Date #2
#############################################################################
date_diff()  {
    if [ "${1}" != "" ] && [ "${2}" != "" ]; then
        echo $((${2} - ${1}))
    else
        echo 0
    fi
}

#############################################################################
# Purpose: Convert a date from MONTH-DAY-YEAR to Julian format
# Acknowledgements: Code was adapted from examples in the book
#                   "Shell Scripting Recipes: A Problem-Solution Approach"
#                   ( ISBN 1590594711 )
# Arguments:
#   $1 -> Month (e.g., 06)
#   $2 -> Day   (e.g., 08)
#   $3 -> Year  (e.g., 2006)
#############################################################################
date2julian() {

    if [ "${1}" != "" ] && [ "${2}" != "" ] && [ "${3}" != "" ]; then
        ## Since leap years add aday at the end of February,
        ## calculations are done from 1 March 0000 (a fictional year)
        d2j_tmpmonth=$((12 * $3 + $1 - 3))

        ## If it is not yet March, the year is changed to the previous year
        d2j_tmpyear=$(( d2j_tmpmonth / 12))

        ## The number of days from 1 March 0000 is calculated
        ## and the number of days from 1 Jan. 4713BC is added
        echo $(( (734 * d2j_tmpmonth + 15) / 24
                 - 2 * d2j_tmpyear + d2j_tmpyear/4
                 - d2j_tmpyear/100 + d2j_tmpyear/400 + $2 + 1721119 ))
    else
        echo 0
    fi
}

#############################################################################
# Purpose: Convert a string month into an integer representation
# Arguments:
#   $1 -> Month name (e.g., Sep)
#############################################################################
getmonth()
{
    case ${1} in
        Jan) echo 1 ;;
        Feb) echo 2 ;;
        Mar) echo 3 ;;
        Apr) echo 4 ;;
        May) echo 5 ;;
        Jun) echo 6 ;;
        Jul) echo 7 ;;
        Aug) echo 8 ;;
        Sep) echo 9 ;;
        Oct) echo 10 ;;
        Nov) echo 11 ;;
        Dec) echo 12 ;;
          *) echo 0 ;;
    esac
}

#####################################################################
# Purpose: Print a line with the expiraton interval
# Arguments:
#   $1 -> Hostname
#   $2 -> TCP Port
#   $3 -> Status of certification (e.g., expired or valid)
#   $4 -> Date when certificate will expire
#   $5 -> Days left until the certificate will expire
#   $6 -> Issuer of the certificate
#   $7 -> Common Name
#   $8 -> Serial Number
#####################################################################
prints()
{
    if [ "${NAGIOSSUMMARY}" = "TRUE" ]; then
        return
    fi

    if [ "${QUIET}" != "TRUE" ] && [ "${ISSUER}" = "TRUE" ] && [ "${VALIDATION}" != "TRUE" ]; then
        MIN_DATE=$(echo "$4" | "${AWK}" '{ printf "%3s %2d %4d", $1, $2, $4 }')
        if [ "${NAGIOS}" = "TRUE" ]; then
            ${PRINTF} "%-35s %-17s %-8s %-11s %s\n" "$1:$2" "$6" "$3" "$MIN_DATE" "|days=$5"
        else
            ${PRINTF} "%-35s %-17s %-8s %-11s %4d\n" "$1:$2" "$6" "$3" "$MIN_DATE" "$5"
        fi
    elif [ "${QUIET}" != "TRUE" ] && [ "${ISSUER}" = "TRUE" ] && [ "${VALIDATION}" = "TRUE" ]; then
        ${PRINTF} "%-35s %-35s %-32s %-17s\n" "$1:$2" "$7" "$8" "$6"

    elif [ "${QUIET}" != "TRUE" ] && [ "${VALIDATION}" != "TRUE" ]; then
        MIN_DATE=$(echo "$4" | "${AWK}" '{ printf "%3s %2d, %4d", $1, $2, $4 }')
        if [ "${NAGIOS}" = "TRUE" ]; then
            ${PRINTF} "%-47s %-12s %-12s %s\n" "$1:$2" "$3" "$MIN_DATE" "|days=$5"
        else
            ${PRINTF} "%-47s %-12s %-12s %4d\n" "$1:$2" "$3" "$MIN_DATE" "$5"
        fi
    elif [ "${QUIET}" != "TRUE" ] && [ "${VALIDATION}" = "TRUE" ]; then
        ${PRINTF} "%-35s %-35s %-32s\n" "$1:$2" "$7" "$8"
    fi
}

####################################################
# Purpose: Print a heading with the relevant columns
# Arguments:
#   None
####################################################
print_heading()
{
    if [ "${NOHEADER}" != "TRUE" ]; then
        if [ "${QUIET}" != "TRUE" ] && [ "${ISSUER}" = "TRUE" ] && [ "${NAGIOS}" != "TRUE" ] && [ "${VALIDATION}" != "TRUE" ]; then
            ${PRINTF} "\n%-35s %-17s %-8s %-11s %-4s\n" "Host" "Issuer" "Status" "Expires" "Days"
            echo "----------------------------------- ----------------- -------- ----------- ----"

        elif [ "${QUIET}" != "TRUE" ] && [ "${ISSUER}" = "TRUE" ] && [ "${NAGIOS}" != "TRUE" ] && [ "${VALIDATION}" = "TRUE" ]; then
            ${PRINTF} "\n%-35s %-35s %-32s %-17s\n" "Host" "Common Name" "Serial #" "Issuer"
            echo "----------------------------------- ----------------------------------- -------------------------------- -----------------"

        elif [ "${QUIET}" != "TRUE" ] && [ "${NAGIOS}" != "TRUE" ] && [ "${VALIDATION}" != "TRUE" ]; then
            ${PRINTF} "\n%-47s %-12s %-12s %-4s\n" "Host" "Status" "Expires" "Days"
            echo "----------------------------------------------- ------------ ------------ ----"

        elif [ "${QUIET}" != "TRUE" ] && [ "${NAGIOS}" != "TRUE" ] && [ "${VALIDATION}" = "TRUE" ]; then
            ${PRINTF} "\n%-35s %-35s %-32s\n" "Host" "Common Name" "Serial #"
            echo "----------------------------------- ----------------------------------- --------------------------------"
        fi
    fi
}

####################################################
# Purpose: Print a summary for nagios
# Arguments:
#   None
####################################################
print_summary()
{
    if [ "${NAGIOSSUMMARY}" != "TRUE" ]; then
        return
    fi

    if [ ${SUMMARY_WILL_EXPIRE} -eq 0 ] && [ ${SUMMARY_EXPIRED} -eq 0 ]; then
        ${PRINTF} "%s valid certificate(s)|days=%s\n" "${SUMMARY_VALID}" "${SUMMARY_MIN_DIFF}"

    elif [ ${SUMMARY_EXPIRED} -ne 0 ]; then
        ${PRINTF} "%s certificate(s) expired (%s:%s on %s)|days=%s\n" "${SUMMARY_EXPIRED}" "${SUMMARY_MIN_HOST}" "${SUMMARY_MIN_PORT}" "${SUMMARY_MIN_DATE}" "${SUMMARY_MIN_DIFF}"

    elif [ ${SUMMARY_WILL_EXPIRE} -ne 0 ]; then
        ${PRINTF} "%s certificate(s) will expire (%s:%s on %s)|days=%s\n" "${SUMMARY_WILL_EXPIRE}" "${SUMMARY_MIN_HOST}" "${SUMMARY_MIN_PORT}" "${SUMMARY_MIN_DATE}" "${SUMMARY_MIN_DIFF}"

    fi
}

#####################################################
### Send email
### Accepts three parameters:
###  $1 -> sender email address
###  $2 -> email to send mail
###  $3 -> Subject
###  $4 -> Message
#####################################################
send_mail() {

    FROM="${1}"
    TO="${2}"
    SUBJECT="${3}"
    MSG="${4}"

    case "${MAILMODE}" in
        "mail")
            echo "$MSG" | "${MAIL}" -r "$FROM" -s "$SUBJECT" "$TO"
            ;;
        "mailx")
            echo "$MSG" | "${MAIL}" -s "$SUBJECT" "$TO"
            ;;
        "sendmail")
            (echo "Subject:$SUBJECT" && echo "TO:$TO" && echo "FROM:$FROM" && echo "$MSG") | "${MAIL}" "$TO"
            ;;
        "*")
            echo "ERROR: You enabled automated alerts, but the mail binary could not be found."
            echo "FIX: Please modify the \${MAIL} and \${MAILMODE} variable in the program header."
            exit 1
            ;;
    esac
}

#############################################################
# Purpose: Set returncode to value if current value is lower
# Arguments:
#   $1 -> New returncorde
#############################################################
set_returncode()
{
    if [ "${RETCODE}" -lt "${1}" ]; then
        RETCODE="${1}"
    fi
}

########################################################################
# Purpose: Set certificate counters and informations for nagios summary
# Arguments:
#   $1 -> Status of certificate (0: valid, 1: will expire, 2: expired)
#   $2 -> Hostname
#   $3 -> TCP Port
#   $4 -> Date when certificate will expire
#   $5 -> Days left until the certificate will expire
########################################################################
set_summary()
{
    if [ "${1}" -eq 0 ]; then
        SUMMARY_VALID=$((SUMMARY_VALID+1))
    elif [ "${1}" -eq 1 ]; then
        SUMMARY_WILL_EXPIRE=$((SUMMARY_WILL_EXPIRE+1))
    else
        SUMMARY_EXPIRED=$((SUMMARY_EXPIRED+1))
    fi

    if [ "${5}" -lt "${SUMMARY_MIN_DIFF}" ] || [ "${SUMMARY_MIN_DIFF}" -eq 0 ]; then
        SUMMARY_MIN_DATE="${4}"
        SUMMARY_MIN_DIFF="${5}"
        SUMMARY_MIN_HOST="${2}"
        SUMMARY_MIN_PORT="${3}"
    fi
}

##########################################
# Purpose: Describe how the script works
# Arguments:
#   None
##########################################
usage()
{
    echo "Usage: $0 [ -e email address ] [-E sender email address] [ -x days ] [-q] [-a] [-b] [-h] [-i] [-n] [-N] [-v]"
    echo "       { [ -s common_name ] && [ -p port] } || { [ -f cert_file ] } || { [ -c cert file ] } || { [ -d cert dir ] }"
    echo ""
    echo "  -a                : Send a warning message through E-mail"
    echo "  -b                : Will not print header"
    echo "  -c cert file      : Print the expiration date for the PEM or PKCS12 formatted certificate in cert file"
    echo "  -d cert directory : Print the expiration date for the PEM or PKCS12 formatted certificates in cert directory"
    echo "  -e E-mail address : E-mail address to send expiration notices"
    echo "  -E E-mail sender  : E-mail address of the sender"
    echo "  -f cert file      : File with a list of FQDNs and ports"
    echo "  -h                : Print this screen"
    echo "  -i                : Print the issuer of the certificate"
    echo "  -k password       : PKCS12 file password"
    echo "  -n                : Run as a Nagios plugin"
    echo "  -N                : Run as a Nagios plugin and output one line summary (implies -n, requires -f or -d)"
    echo "  -p port           : Port to connect to (interactive mode)"
    echo "  -q                : Don't print anything on the console"
    echo "  -s commmon name   : Server to connect to (interactive mode)"
    echo "  -S                : Print validation information"
    echo "  -t type           : Specify the certificate type"
    echo "  -V                : Print version information"
    echo "  -x days           : Certificate expiration interval (eg. if cert_date < days)"
    echo ""
}

checkOS ()
{

    if [[ $(uname -m) == 'arm64' ]]; then
        echo " --> good morning , on macOS "
        macOS="TRUE"
    else
        echo " --> hello, on windows "
        macOS="FALSE"
        
    fi
}

#################################
### Start of main program
#################################
while getopts abc:d:e:E:f:hik:nNp:qs:St:Vx: option
do
    case "${option}" in
        a) ALARM="TRUE";;
        b) NOHEADER="TRUE";;
        c) CERTFILE=${OPTARG};;
        d) CERTDIRECTORY=${OPTARG};;
        e) ADMIN=${OPTARG};;
        E) SENDER=${OPTARG};;
        f) SERVERFILE=$OPTARG;;
        h) usage
           exit 1;;
        i) ISSUER="TRUE";;
        k) PKCSDBPASSWD=${OPTARG};;
        n) NAGIOS="TRUE";;
        N) NAGIOS="TRUE"
           NAGIOSSUMMARY="TRUE";;
        p) PORT=$OPTARG;;
        q) QUIET="TRUE";;
        s) HOST=$OPTARG;;
        S) VALIDATION="TRUE";;
        t) CERTTYPE=$OPTARG;;
        v) echo " Verbose mode ";;
        V) echo "${PROGRAMVERSION}"
           exit 0
        ;;
        x) WARNDAYS=$OPTARG;;
       \?) usage
           exit 1;;
    esac
done

#######################################
## Check for pre-req software 
## SANJAY 
#######################################

if [ ${DEBUG} = "TRUE" ]; then
    echo " --> macOS " ${macOS}
fi 

checkOS

if [ ${DEBUG} = "TRUE" ]; then
    echo " --> within prereqs"
fi 

## AWK
### Check to make sure the awk utility is available
if [ ! -f "${AWK}" ]; then
    echo "ERROR: The awk binary does not exist."
    echo "FIX: Please modify the \${AWK} variable in the program header."
    exit 1
fi

## DATE
### Check to make sure a date utility is available
if [ ! -f "${DATE}" ]; then
    echo "ERROR: The date binary does not exist."
    echo "FIX: Please modify the \${DATE} variable in the program header."
    exit 1
fi

## ECHO
### Check to make sure a echo utility is available
##if [ ! -f "${ECHO}" ]; then
##      ${ECHO} "ERROR: The echo binary does not exist in ${ECHO} ."
##    echo "FIX: Please modify the \${ECHO} variable in the program header."
##    exit 1
##fi

## GREP
### Check to make sure a find and grep utilities are available
if [ ! -f "${GREP}" ] || [ ! -f "${FIND}" ]; then
    echo "ERROR: The grep and find binaries do not exist."
    echo "FIX: Please modify the \${GREP} and \${FIND} variables in the program header."
    exit 1
fi

## MKDIR
### Check to make sure the mktemp and printf utilities are available
if [ ! -f "${MKDIR}" ]; then
    echo "ERROR: The mkdir binary does not exist."
    echo "FIX: Please modify the \${MKDIR} variable in the program header."
    exit 1
fi

## MKTEMP
### Check to make sure the mktemp and printf utilities are available
if [ ! -f "${MKTEMP}" ] || [ -z "${PRINTF}" ]; then
    echo "ERROR: The mktemp and printf binaries do not exist."
    echo "FIX: Please modify the \${MKTEMP} and \${PRINTF} variables in the program header."
    exit 1
fi

## OPENSSL
### Check to make sure the openssl utility is available
if [ ! -f "${OPENSSL}" ]; then
    echo "ERROR: The openssl binary does not exist."
    echo "FIX: Please modify the \${OPENSSL} variable in the program header."
    exit 1
fi

## RM
### Check to make sure the rm utility is available
if [ ! -f "${RM}" ]; then
    echo "ERROR: The rm binary does not exist."
    echo "FIX: Please modify the \${RM}  variable in the program header."
    exit 1
fi

## SED
### Check to make sure the sed utility is available
if [ ! -f "${SED}" ]; then
    echo "ERROR: The sed binary does not exist. "
    echo "FIX: Please modify the \${SED} variable in the program header."
    exit 1
fi

## TOUCH
### Check to make sure the touch utility is available
if [ ! -f "${TOUCH}" ]; then
    echo "ERROR: The touch binary does not exist. "
    echo "FIX: Please modify the \${TOUCH} variable in the program header."
    exit 1
fi

## UNAME
### Check to make sure the sed utility is available
if [ ! -f "${UNAME}" ]; then
    echo "ERROR: The uname binary does not exist ."
    echo "FIX: Please modify the \${UNAME}  variable in the program header."
    exit 1
fi

## END of PRE-REQS
#############################

## LOG DIRS

if [ ${macOS} = "TRUE" ]; then
    if [ ${DEBUG} = "TRUE" ]; then
        echo " --> if macOS : true "
    fi
        REPORT_DIR=/Users/sjairam/was/dgadmin/logs/sslCheck
        tempFile=$REPORT_DIR/$file-$dateTime-A.csv
        LOGDIR=$REPORT_DIR/$file-$dateTime.csv
    else
        if [ ${DEBUG} = "TRUE" ]; then
            echo " --> if macOS : false "
        fi
        REPORT_DIR=/Users/sjairam/was/dgadmin/logs/sslCheck
        tempFile=$dREPORT_DIRir/$file-$dateTime-A.csv
        LOGDIR=$REPORT_DIR/$file-$dateTime.csv

fi

if [ ! -d ${REPORT_DIR} ]; 
then
	mkdir ${REPORT_DIR}
fi 


### Check to make sure a mail client is available it automated notifications are requested
if [ "${ALARM}" = "TRUE" ] && [ ! -f "${MAIL}" ]; then
    echo "ERROR: You enabled automated alerts, but the mail binary could not be found."
    echo "FIX: Please modify the ${MAIL} variable in the program header."
    exit 1
fi

# Send along the servername when TLS is used
if ${OPENSSL} s_client -help 2>&1 | grep '-servername' > /dev/null; then
    TLSSERVERNAME="TRUE"
else
    TLSSERVERNAME="FALSE"
fi

# Place to stash temporary files
CERT_TMP=$($MKTEMP /var/tmp/cert.XXXXXX)
ERROR_TMP=$($MKTEMP /var/tmp/error.XXXXXX)

### Baseline the dates so we have something to compare to
MONTH=$(${DATE} "+%m")
DAY=$(${DATE} "+%d")
YEAR=$(${DATE} "+%Y")
NOWJULIAN=$(date2julian "${MONTH#0}" "${DAY#0}" "${YEAR}")

### Touch the files prior to using them
if [ -n "${CERT_TMP}" ] && [ -n "${ERROR_TMP}" ]; then
    touch "${CERT_TMP}" "${ERROR_TMP}"
else
    echo "ERROR: Problem creating temporary files"
    echo "FIX: Check that mktemp works on your system"
    exit 1
fi

if [ ${DEBUG} = "TRUE" ]; then
    echo " --> Before Host parameter passed "
fi 

########################################################
## If a HOST was passed on the cmdline, use that value
########################################################
if [ "${HOST}" != "" ]; then
    print_heading
    check_server_status "${HOST}" "${PORT:=443}"
    print_summary
########################################################
## If a FILE (-f)   was passed on the cmdline, use that value
########################################################
elif [ -f "${SERVERFILE}" ]; then

    if [ ${DEBUG} = "TRUE" ]; then        
        echo " --> In file ELSE IF --> "
    fi 

    print_heading  | tee -a ${LOGDIR}

    IFS=$'\n'
    for LINE in $(grep -E -v '(^#|^$)' "${SERVERFILE}")
    do
        HOST=${LINE%% *}
        PORT=${LINE##* }
        IFS=" "
        if [ "$PORT" = "FILE" ]; then

            check_file_status "${HOST}" "FILE" "${HOST}" | tee -a ${LOGDIR}
        else
            
            check_server_status "${HOST}" "${PORT}" | tee -a ${LOGDIR}
        fi
    done
    IFS="${OLDIFS}"
    print_summary | tee -a ${LOGDIR}
    
########################################################
## If a CERT was passed on the cmdline, use that value
########################################################
elif [ "${CERTFILE}" != "" ]; then
    print_heading
    check_file_status "${CERTFILE}" "FILE" "${CERTFILE}"
    print_summary

### Check to see if the certificates in CERTDIRECTORY are about to expire
elif [ "${CERTDIRECTORY}" != "" ] && ("${FIND}" -L "${CERTDIRECTORY}" -type f > /dev/null 2>&1); then
    print_heading
    for FILE in $("${FIND}" -L "${CERTDIRECTORY}" -type f); do
        check_file_status "${FILE}" "FILE" "${FILE}"
    done
    print_summary
### There was an error, so print a detailed usage message and exit
else
    usage
    exit 1
fi

### Exit with a success indicator
if [ "${NAGIOS}" = "TRUE" ]; then
    exit "${RETCODE}"
else
    exit 0
fi
