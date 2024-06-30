#!/bin/bash
# 01 - initial - sjairam
# 02 - Add arn check
# 03 - Add arn as parameter 1
# 04 - Add AWS Clit - sjairam

# If no ArN is provided this variable can be enabled:  List all load balancers and get their ARNs
load_balancer_arns=$(aws elbv2 describe-load-balancers --query "LoadBalancers[*].LoadBalancerArn" --output text)

# Check if aws cli is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

#Overrides list ARN above
load_balancer_arns=$1

for lb_arn in $load_balancer_arns; do
    echo "Load Balancer ARN: $lb_arn"
    
    # List listeners for each load balancer
    listener_arns=$(aws elbv2 describe-listeners --load-balancer-arn $lb_arn --query "Listeners[*].ListenerArn" --output text)
    
    for listener_arn in $listener_arns; do
        echo "  Listener ARN: $listener_arn"
        
        # List certificates for each listener
        certificates=$(aws elbv2 describe-listener-certificates --listener-arn $listener_arn --query "Certificates[*].CertificateArn" --output text)
        
        for cert in $certificates; do
            echo "    Certificate ARN: $cert"
        done
    done
done

