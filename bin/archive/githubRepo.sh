#!/bin/bash
VERSION=0.1
# Use this script AFTER cloning ips-template-api 
#############################
## Location binaries
#############################
AWK=$(command -v awk)
FIND=$(command -v find)
GREP=$(command -v grep)
SED=$(command -v sed)
SLEEP=$(command -v sleep)

if [ "$#" -ne 1 ]; then
  echo " You have to provide the gitHub repo name "
  exit 3;
fi

#If gh not installed, invoke install
function ghInstall {
    SYS=`uname -o 2>/dev/null`
    if [ $? -eq 0 ]; then
        echo " in windows "
        choco install gh
    else
        echo "SYS: Something better than Windows ;)"
        brew install gh
    fi   
}

clear 

echo " --> traverse into folder "
# remove mkdir, once incorporated (remove mkdir due to Paul`s repo change`)
cd $1
sleep 3
touch README.md

## echo " --> init git "
##git init
##sleep 3

echo " --> add git "
git add .
sleep 3

echo " --> initial commit "
git commit -m "updated references"
sleep 3

echo " --> git branch "
git branch -M main

##echo " --> GH login "
# Enable for other admins
##gh auth login
## echo " --> add files repo "
## git remote add origin git@github.com:domgen/$1.git

# BUg 1492
##gh repo create $1 --internal --source=. --remote=upstream --push
##git push -u origin main
##git push --set-upstream origin main
echo " --> push gitHub "
git push 

echo " "
echo " ++++ files added to github ++++ "
