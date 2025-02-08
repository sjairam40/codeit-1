#!/bin/bash
clear

echo " --> Rolling ACORN"
kubectl rollout restart deployment acorn-server -n acorn

echo " --> Rolling ARCHECKER"
kubectl rollout restart deployment archecker -n archecker

echo " --> Rolling ARCLIGHT"
kubectl rollout restart deployment arclight -n arclight
kubectl rollout restart deployment pipeline -n arclight

echo " --> Rolling BOOKLABELER"
kubectl rollout restart deployment.apps/booklabeler -n booklabeler

echo " --> Rolling CURIOSITY"
kubectl rollout restart deployment.apps/curiosity -n curiosity
kubectl rollout restart deployment.apps/curiosityworker -n curiosity

echo " --> Rolling COLLEX"
kubectl rollout restart deployment.apps/collex-airflow-pgbouncer-deploy -n collex
kubectl rollout restart deployment.apps/collex-airflow-scheduler-deploy -n collex
kubectl rollout restart deployment.apps/collex-airflow-triggerer-deploy -n collex
kubectl rollout restart deployment.apps/collex-airflow-webserver-deploy -n collex

echo " --> Rolling DAIS"
kubectl rollout restart deployment.apps/dims -n dais
kubectl rollout restart deployment.apps/dts -n dais
kubectl rollout restart deployment.apps/int-tests -n dais
kubectl rollout restart deployment.apps/notifier -n dais
kubectl rollout restart deployment.apps/rabbitmq-email-notifier -n dais
kubectl rollout restart deployment.apps/transfer-service -n dais

echo " --> Rolling EDA"
kubectl rollout restart deployment.apps/eda -n eda
kubectl rollout restart deployment.apps/eda-iip -n eda
kubectl rollout restart deployment.apps/eda-mc -n eda

echo " --> Rolling ETD"
kubectl rollout restart deployment.apps/etd-alma-drs-holding-service -n etd
kubectl rollout restart deployment.apps/etd-alma-monitor-service -n etd
kubectl rollout restart deployment.apps/etd-alma-service -n etd
kubectl rollout restart deployment.apps/etd-dash-service -n etd
kubectl rollout restart deployment.apps/etd-int-tests -n etd

echo " --> Rolling FTS"
kubectl rollout restart deployment.apps/api -n fts
kubectl rollout restart deployment.apps/loader -n fts
kubectl rollout restart deployment.apps/proxy -n fts
kubectl rollout restart deployment.apps/ui -n fts

echo " --> Rolling HDFORMS"
kubectl rollout restart deployment.apps/hdforms -n hdforms

echo " --> Rolling HGL"
kubectl rollout restart  deployment.apps/gbl -n hgl
kubectl rollout restart  deployment.apps/geoserver -n hgl

echo " --> Rolling LTS-PIPELINES "
kubectl rollout restart deployment.apps/lts-pipelines-airflow-scheduler -n lts-pipelines
kubectl rollout restart deployment.apps/lts-pipelines-airflow-triggerer -n lts-pipelines
kubectl rollout restart deployment.apps/lts-pipelines-airflow-webserver -n lts-pipelines
kubectl rollout restart deployment.apps/lts-pipelines-airflow-worker -n lts-pipelines

echo " --> Rolling IDS "
kubectl rollout restart deployment.apps/ids -n ids
kubectl rollout restart deployment.apps/idsmd -n ids
kubectl rollout restart deployment.apps/iiif -n ids
kubectl rollout restart deployment.apps/iiif-updater -n ids
kubectl rollout restart deployment.apps/pds -n ids

echo " --> Rolling IMGCONV "
kubectl rollout restart deployment.apps/imgconv -n imgconv

echo " --> Rolling JOBMONITOR "
kubectl rollout restart deployment.apps/jobmonitor -n jobmonitor

echo " --> Rolling JSTOR "
kubectl rollout restart deployment.apps/jstor-aggregator -n jstor
kubectl rollout restart deployment.apps/jstor-harvester -n jstor
kubectl rollout restart deployment.apps/jstor-integration -n jstor
kubectl rollout restart deployment.apps/jstor-publisher -n jstor
kubectl rollout restart deployment.apps/jstor-transformer -n jstor

echo " --> Rolling LIBRARYCLOUD"
kubectl rollout restart deployment.apps/lc-collections -n librarycloud
kubectl rollout restart deployment.apps/lc-collectionsbuilder -n librarycloud
kubectl rollout restart deployment.apps/lc-csv -n librarycloud
kubectl rollout restart deployment.apps/lc-ingest -n librarycloud
kubectl rollout restart deployment.apps/lc-oai -n librarycloud
kubectl rollout restart deployment.apps/librarycloud -n librarycloud

echo " --> Rolling LISTVIEW"
kubectl rollout restart deployment.apps/listview -n listview
kubectl rollout restart deployment.apps/listview-md -n listview

echo " --> Rolling MDS"
kubectl rollout restart deployment.apps/mdsrv -n mds
kubectl rollout restart deployment.apps/mqsrv -n mds
kubectl rollout restart deployment.apps/ocfl-storage-ro -n mds
kubectl rollout restart deployment.apps/s3pather -n mds
kubectl rollout restart deployment.apps/solr2mds -n mds


echo " --> Rolling Whistle"
kubectl rollout restart deployment.apps/whistle -n whistle