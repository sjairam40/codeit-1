#!/bin/bash

# Function to retrieve and display RDS instance details
get_rds_info() {
  # List all the RDS instances using AWS CLI
  aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier, DBInstanceStatus, Engine, LatestRestorableTime]" --output text | while read -r line; do
    # Split the line into separate fields
    IFS=$'\t' read -r instance_name instance_status engine latest_restorable_time <<< "$line"
    
    # Display the instance details
    echo "Instance Name: $instance_name"
    echo "Status: $instance_status"
    echo "Engine: $engine"
    
    # Getting the current activity for each instance
    activity=$(aws rds describe-db-instances --db-instance-identifier "$instance_name" --query "DBInstances[*].LatestRestorableTime" --output text)
    
    # Check if there is any activity information available
    if [ -z "$activity" ]; then
      echo "Current Activity: N/A"
    else
      echo "Current Activity: $activity"
    fi
    echo "-----------------------------------"
  done
}

# Execute the function
get_rds_info