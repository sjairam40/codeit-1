#!/bin/bash
version=0.1

AWS=$(command -v aws)

CAT=$(command -v cat)

KUBECTL=$(command -v kubectl)

# Create SSL Certificate Kubernetes Secrets
aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-cert --query SecretString --output text|tr -d '"' > /tmp/tls.crt
aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-key --query SecretString --output text|tr -d '"' > /tmp/tls.key


#### AWS
#### Check to make sure the aws cli utility is available
if [ ! -f "${AWS}" ]; then
    echo "ERROR: Unable to locate the AWS CLI binary."
    echo "FIX: Please modify the \${AWS} variable in the program header."
    exit 1
fi

#### CAT
#### Check to make sure the cat utility is available
if [ ! -f "${CAT}" ]; then
    echo "ERROR: Unable to locate the cat binary."
    echo "FIX: Please modify the \${CAT} variable in the program header."
    exit 1
fi

#### KUBECTL
#### Check to make sure the kubectl utility is available
if [ ! -f "${KUBECTL}" ]; then
    echo "ERROR: Unable to locate the AWS CLI binary."
    echo "FIX: Please modify the \${KUBECTL} variable in the program header."
    exit 1
fi

#### UNIQ
#### Check to make sure the uname utility is available
if [ ! -f "${UNIQ}" ]; then
    echo "ERROR: Unable to locate the uniq binary."
    echo "FIX: Please modify the \${UNIQ} variables in the program header."
    exit 1
fi

kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=/tmp/tls.crt --key=/tmp/tls.key

# Update Rancher with SSL Certificate
helm upgrade -i rancher rancher-latest/rancher --namespace cattle-system --version ${rancher_version} --set hostname=${hostname} --set bootstrapPassword="${rancher_password}" --set ingress.tls.source=secret --set replicas=1

