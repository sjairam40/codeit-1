#!/bin/bash
# 01 - initial - jairams
# 02 - Add AWS CLI check

# Check if aws cli is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# List all load balancers and get their names and ARNs
load_balancers=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?Type=='application'].{Name:LoadBalancerName, ARN:LoadBalancerArn}" --output text)

# Check if there are any ALBs found
if [ -z "$load_balancers" ]; then
    echo "No Application Load Balancers found."
else
    echo "Application Load Balancers:"
    echo "$load_balancers"
fi
