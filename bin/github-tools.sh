#!/bin/bash

start_time=$(date +%s)

month=`date +%b`

year=`date +%y`


cd ~/Documents/GitHub/
mkdir TOOLS
cd TOOLS

echo "  --> alertmanager "
git clone git@github.com:prometheus/alertmanager.git

echo " --> argocd"
git clone git@github.com:argoproj/argo-cd.git

echo " --> aws ebs driver"
git clone git@github.com:kubernetes-sigs/aws-ebs-csi-driver.git

echo " --> csi nfs driver"
git clone git@github.com:kubernetes-csi/csi-driver-nfs.git

echo " --> iamlive"
git clone git@github.com:iann0036/iamlive.git

echo " --> ISTIO" 
git clone git@github.com:istio/istio.git

echo " --> jaeger"
git clone git@github.com:jaegertracing/jaeger.git


echo " --> popeye"
git clone git@github.com:derailed/popeye.git

echo " --> samber/prometheus"
git clone git@github.com:samber/awesome-prometheus-alerts.git


end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

echo " ====================================================== "
# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"