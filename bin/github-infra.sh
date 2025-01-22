#!/bin/bash

start_time=$(date +%s)

month=`date +%b`

year=`date +%y`

clear

echo " ==>> Creating repos "

cd ~/Documents/GitHub/
mkdir APPS-INFRA
cd APPS-INFRA

echo " --> A to L"

git clone git@github.huit.harvard.edu:LTS/ACORN-INFRA.git

git clone git@github.huit.harvard.edu:LTS/archecker-INFRA.git

git clone git@github.huit.harvard.edu:LTS/argoCD-INFRA.git

git clone git@github.huit.harvard.edu:LTS/aspace-INFRA.git

git clone git@github.huit.harvard.edu:LTS/bibdatalookup-INFRA.git

git clone git@github.huit.harvard.edu:LTS/booklabeler-INFRA.git

git clone git@github.huit.harvard.edu:LTS/curiosity-INFRA.git

git clone git@github.huit.harvard.edu:LTS/DAIS-INFRA.git

git clone git@github.huit.harvard.edu:LTS/DRS2-INFRA.git

git clone git@github.huit.harvard.edu:LTS/devsecops-INFRA.git

git clone git@github.huit.harvard.edu:LTS/fts-INFRA.git

git clone git@github.huit.harvard.edu:LTS/HDForms-INFRA.git

git clone git@github.huit.harvard.edu:LTS/hgl-INFRA.git

git clone git@github.huit.harvard.edu:LTS/IDS-INFRA.git

git clone git@github.huit.harvard.edu:LTS/imgconv-INFRA.git

git clone git@github.huit.harvard.edu:LTS/jobmonitor-INFRA.git

git clone git@github.huit.harvard.edu:LTS/JSTOR-INFRA.git

git clone git@github.huit.harvard.edu:LTS/LISTVIEW-INFRA.git

git clone git@github.huit.harvard.edu:LTS/lts-pipelines-INFRA.git

echo " --> M to Z"

git clone git@github.huit.harvard.edu:LTS/mds-INFRA.git

git clone git@github.huit.harvard.edu:LTS/mps-INFRA.git

git clone git@github.huit.harvard.edu:LTS/mpsadm-INFRA.git

git clone git@github.huit.harvard.edu:LTS/nrs-INFRA.git

git clone git@github.huit.harvard.edu:LTS/nrsadm-INFRA.git

git clone git@github.huit.harvard.edu:LTS/olivia-INFRA.git

git clone git@github.huit.harvard.edu:LTS/policy-INFRA.git

git clone git@github.huit.harvard.edu:LTS/presto-INFRA.git

git clone git@github.huit.harvard.edu:LTS/SDS-and-Wowza-INFRA.git

git clone git@github.huit.harvard.edu:LTS/talkwithhollis-INFRA.git

git clone git@github.huit.harvard.edu:LTS/viewer-INFRA.git

end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

echo " ====================================================== "
# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"