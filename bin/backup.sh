#!/bin/bash


start_time=$(date +%s)

echo " --> Going to USB"
cd /Volumes/Data2024/

month=`date +%b`
echo " --> Creating Month docco"
timeSec=2

DOCCO='Documents-$month-2024'

if [ ! -d ${DOCCO} ]; 
then
    mkdir Documents-$month-2024
    mkdir Documents-$month-2024/01-kube
    mkdir Documents-$month-2024/02-ssh
    mkdir Documents-$month-2024/03-shells
    mkdir Documents-$month-2024/04-aws
    mkdir Documents-$month-2024/Pictures
    mkdir Documents-$month-2024/Movies
else 
    echo " --> Folder exists"
fi

echo " --> Going to Docs"
cd ~/Documents
sleep $timeSec

echo " --> cp shells "
cp -R ~/.aliases  /Volumes/Data2024/Documents-$month-2024/03-shells
cp -R ~/.bashrc  /Volumes/Data2024/Documents-$month-2024/03-shells
cp -R ~/.zshrc  /Volumes/Data2024/Documents-$month-2024/03-shells
sleep $timeSec

echo " --> cp .kube "
cp -R ~/.kube  /Volumes/Data2024/Documents-$month-2024/01-kube
cp ~/.kube/*.txt /Volumes/Data2024/Documents-$month-2024/01-kube
cp ~/.kube/*.crt /Volumes/Data2024/Documents-$month-2024/01-kube
sleep $timeSec

echo " --> cp .ssh "
cp -R ~/.ssh  /Volumes/Data2024/Documents-$month-2024/02-ssh
sleep $timeSec

echo " --> cp .aws "
cp -R ~/.aws  /Volumes/Data2024/Documents-$month-2024/04-aws
sleep $timeSec

echo " --> cp passwords "
cp -R ~/Passwords.kdb*  /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 00-docs"
cp -R 00-docs-00 /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 00-personal"
cp -R 00-personal-00 /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 1-SANDBOX*"
cp -R 1-SAND* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 2-SANDBOX*"
cp -R 2-SAND* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 4-DEV"
cp -R 4-DEV* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 5-QA"
cp -R 5-QA* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 6-PROD"
cp -R 6-PROD* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 7-LZPROD"
cp -R 7-LZPROD* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying A*"
cp -R A* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying C*"
cp -R C* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying D*"
cp -R D* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copying 0 txts"
cp -R 0*.txt /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy DEMO"
cp -R DEMOS /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy D&G"
cp -R Domestic* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

# echo " --> Copy GitHub"
# cp -R GitHub* /Volumes/Data2024/Documents-$month-2024/
# sleep $timeSec

echo " --> Copy E*"
cp -R E* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy G*"
cp -R G* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy Harvard"
cp -R HARVARD* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy ISTIO"
cp -R ISTIO* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy J*"
cp -R J* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy K*"
cp -R K* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy Orca"
cp -R ORCA* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy P*"
cp -R P* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy RKE"
cp -R RKE* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy T*"
cp -R T* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy Zoom"
cp -R Zoom* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy zz-home"
cp -R zz-home* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy zz-notes"
cp -R zz-notes* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " --> Copy Installed"
cp -R zz-installed* /Volumes/Data2024/Documents-$month-2024/
sleep $timeSec

echo " ###>> Going to Pictures"
cd ~/Pictures
sleep $timeSec

echo " --> Copy 00-oteemo"
cp -R 00-oteemo* /Volumes/Data2024/Documents-$month-2024/Pictures
sleep $timeSec

echo " --> Copy 00-personal"
cp -R 00-personal* /Volumes/Data2024/Documents-$month-2024/Pictures
sleep $timeSec

echo " --> Copy Background"
cp -R Background* /Volumes/Data2024/Documents-$month-2024/Pictures
sleep $timeSec

echo " --> Copy HARVARD"
cp -R HARVARD* /Volumes/Data2024/Documents-$month-2024/Pictures
sleep $timeSec

echo " ###>> Going to Movies"
cd ~/Movies

echo " --> Going to 07"
cp -R 0723* /Volumes/Data2024/Documents-$month-2024/Movies
sleep $timeSec

echo " --> Going to 09"
cp -R 0823* /Volumes/Data2024/Documents-$month-2024/Movies
sleep $timeSec

cp -R 0923* /Volumes/Data2024/Documents-$month-2024/Movies
sleep $timeSec

echo " --> Going to HUMOUR"
cp -R HUMOUR* /Volumes/Data2024/Documents-$month-2024/Movies
sleep $timeSec

echo " --> Going to LEARNING"
cp -R LEARNING /Volumes/Data2024/Documents-$month-2024/Movies
sleep $timeSec

sleep $timeSec

end_time=$(date +%s)

elapsed_time=$(( end_time - start_time ))

# Convert elapsed time to minutes and seconds
elapsed_minutes=$(( elapsed_time / 60 ))
elapsed_seconds=$(( elapsed_time % 60 ))

# Output the result
echo "Elapsed time: $elapsed_minutes minutes and $elapsed_seconds seconds"