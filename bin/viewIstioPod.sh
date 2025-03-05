#!/bin/bash
# You have to be in the NS

# Check if the number of arguments is correct
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <pod-name>"
    exit 1
fi

clear

# Assign the first argument to the POD_NAME variable
POD_NAME=$1

# Run the kubectl logs command with the specified pod name
kubectl logs -f "$POD_NAME" -c istio-proxy