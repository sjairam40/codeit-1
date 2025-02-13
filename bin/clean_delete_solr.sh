#!/bin/bash
# 01 - initial - jairams
# 02 - Add AWS CLI check

AWS=$(command -v aws)

if [ ! -f "${AWS}" ]; then
    echo "ERROR: The aws binary does not exist."
    echo "FIX: Please modify the \${AWS} variable in the program header."
    exit 1
fi

echo " --> Delete NS Solr "
kubectl delete ns solr
sleep 5

echo " --> Delete NS solr-operator"
kubectl delete ns solr-operator
sleep 5

echo " --> Delete CRD solr-operator"
kubectl delete crd solr-operator-zookeeper-operator
sleep 4

echo " --> Delete CRD solrbackups.solr.apache.org"
kubectl delete crd solrbackups.solr.apache.org
sleep 4

echo " --> Delete CRD solrprometheusexporters"
kubectl delete crd  solrprometheusexporters.solr.apache.org
sleep 4
