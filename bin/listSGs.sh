#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if a region is provided as an argument
if [ $# -eq 0 ]
then
    echo "Please provide an AWS region as an argument."
    echo "Usage: $0 <aws-region>"
    exit 1
fi

REGION=$1

# List all security groups and their descriptions
aws ec2 describe-security-groups \
    --region $REGION \
    --query 'SecurityGroups[].[GroupId,GroupName,Description]' \
    --output table