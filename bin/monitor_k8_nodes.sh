#!/bin/bash

# Function to get the node statuses
function check_nodes() {
  echo "Checking Kubernetes Nodes..."

  # Get all nodes and their statuses
  nodes=$(kubectl get nodes --no-headers | awk '{print $1}')

  for node in $nodes; do
    echo "Node: $node"

    # Get the overall status of the node
    node_status=$(kubectl get node $node --no-headers | awk '{print $2}')
    echo "  Overall Status: $node_status"

    # Get node conditions (Ready, MemoryPressure, DiskPressure, etc.)
    kubectl describe node $node | grep -A 1 "Conditions:" | grep -E "Ready|MemoryPressure|DiskPressure|PIDPressure" | awk '{print "  Condition: "$1", Status: "$2}'

    # Optional: Get CPU and Memory usage on the node (via metrics-server, if installed)
    echo "  Resource Usage:"
    kubectl top node $node --no-headers 2>/dev/null | awk '{print "    CPU Usage: "$2", Memory Usage: "$3}'

    echo ""
  done
}

# Run the check every 60 seconds (you can change this interval)
while true; do
  check_nodes
  sleep 60
done

