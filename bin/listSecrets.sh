#!/bin/bash
# 01 - initial - jairams
# 02 - Add AWS CLI check

# Check if aws cli is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

clear

# Function to list all secrets
list_all_secrets() {
    aws secretsmanager list-secrets --query 'SecretList[*].Name' --output text
}

# Function to describe a secret and get key-value pairs
describe_secret() {
    local secret_name="$1"
    secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_name" --query 'SecretString' --output text)
    echo "Secret Name: $secret_name"
    echo "Key-Value Pairs:"
    echo "$secret_value" | jq
}

# Main script logic
if [ "$#" -eq 0 ]; then
    echo "Listing all secrets:"
    all_secrets=$(list_all_secrets)
    for secret in $all_secrets; do
        describe_secret "$secret"
    done
else
    secret_name="$1"
    describe_secret "$secret_name"
fi
