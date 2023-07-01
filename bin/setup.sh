#!/bin/bash

# AWS variables
AWS_PROFILE=default
AWS_REGION=us-east-1

# project variables
PROJECT_NAME=aws-docker-github-kubernetes
WEBSITE_PORT=3000

# the directory containing the script file
export dir="$(cd "$(dirname "$0")"; pwd)"

echo ' dir '+ $dir
cd "$dir"

log()   { echo -e " $1 "; }      # $1 uppercase background white
info()  { echo -e " $1 "; }      # $1 uppercase background green
warn()  { echo -e " $1 "; }
error() { echo -e " $1 "; }

info() {
  printf "\r\033[00;35m$1\033[0m\n"
}

success() {
  printf "\r\033[00;32m$1\033[0m\n"
}

fail() {
  printf "\r\033[0;31m$1\033[0m\n"
}

#log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }        # $1 uppercase background white
#info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }      # $1 uppercase background green
#warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background orange
#error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background red

####################
## DEFAULT FUNCTION
####################

installAPP(){
   # t stores $1 argument passed to installAPP
    t=$1
    echo " installAPP(): \$1 is $1"

    if [[ -z $(which $1 ) ]]
    then
        info " ----> installing $1 " | tee -a ~/install.log
        brew install --cask $1
    else
        info " ##>> $1  already installed ! " | tee -a ~/install.log
    fi

}

under() {
    local arg=$1
    #shift
    echo -e " ${arg} "
    echo
}

usage() {
    under usage 'call the Makefile directly: make dev
      or invoke this file directly: ./make.sh dev'
}

########################
## ADOBE ACROBAT READER
########################
installADOBEREADER () {

    if [[ -z $(which adobe-acrobat-reader) ]]
    then
        echo ' ----> installing adobe-acrobat-reader '  | tee -a ~/install.log
        brew install --cask adobe-acrobat-reader
    else 
        info " --> adobe-acrobat-reader already installed" | tee -a ~/install.log
    fi
}

###########
## AWS IAM 
###########
installAWSIAMauth () {

    if [[ -z $(which aws-iam-authenticator) ]]
    then
        echo ' ----> installing aws-iam-authenticator ' | tee -a ~/install.log
        brew install aws-iam-authenticator
    else 
        info " --> aws-iam-authenticator already installed" | tee -a ~/install.log
    fi
}

##########
## DOCKER 
##########
installDOCKER () {
        
    if [[ -z $(which docker) ]]
    then
        echo ' ----> installing docker ' | tee -a ~/install.log
        brew install --cask docker
    else
        info " --> docker already installed ! " | tee -a ~/install.log
    fi
}

##########
## EKSCTL 
##########
installEKSCTL () {

    if [[ -z $(which eksctl) ]]
    then
        echo ' ----> installing eksctl  ' | tee -a ~/install.log
        brew install eksctl 
    else 
        log " --> eksctl already installed" | tee -a ~/install.log
    fi
}

##########
## GH  
##########
installGH () {

    if [[ -z $(which gh) ]]
    then
        echo ' ----> installing gh ' | tee -a ~/install.log
        brew install gh
    else
        log " --> gh already installed." | tee -a ~/install.log
    fi
}

##########
## HELM
##########
installHELM () {

    if [[ -z $(which helm) ]]
    then
        echo ' ----> installing helm ' | tee -a ~/install.log
        brew install helm
    else
        log " --> helm already installed." | tee -a ~/install.log
    fi
}

##########
## ITERM  
##########
installITERM () {

    if [[ -z $(which iterm2) ]]
    then
        echo ' ----> installing iterm2 ' | tee -a ~/install.log
        brew install --cask iterm2
    else
        log " --> iterm2 already installed." | tee -a ~/install.log
    fi
}

##########
## JQ  
##########
installJQ () {

    if [[ -z $(which jq) ]]
    then
        echo ' ----> installing jq ' | tee -a ~/install.log
        brew install jq
    else
        log " --> jq already installed." | tee -a ~/install.log
    fi
}

#############
## KEEPASSXC
#############
installKEEPASS() {
    # brew install --cask keepassxc
    if [[ -z $(which keepassxc) ]]
    then
        echo ' ----> installing keepass ' | tee -a ~/install.log
        brew install --cask keepassxc
    else
        log " --> keepassxc already installed." | tee -a ~/install.log
    fi
}

###########
## KUBECTL  
###########
installKUBECTL () {

    if [[ -z $(which kubectl) ]]
    then
        echo ' ----> installing kubectl ' | tee -a ~/install.log
        brew install kubectl
    else
        log " --> kubectl already installed." | tee -a ~/install.log
    fi
}

#################
## LITTLE-SNITCH 
#################
installLITTLESNITCH ()
{

    if [[ -z $(which minikube) ]]
    then
        echo ' ----> installing little snitch ' | tee -a ~/install.log
        brew install --cask little-snitch
    else
        log " --> minikube already installed." | tee -a ~/install.log
    fi

}

############
## MINKUBE 
############
installMINIKUBE ()
{
    if [[ -z $(which hyperkit) ]]
    then
        echo ' ----> installing hyperkit ' | tee -a ~/install.log
        brew install hyperkit
    else
        if [[ -z $(which minikube) ]]
        then
            echo ' ----> installing minkube ' | tee -a ~/install.log
            brew install minikube
        else
            log " --> minikube already installed." | tee -a ~/install.log
        fi
    fi
}

###########
## POSTMAN
###########
installPOSTMAN () {
        
    if [[ -z $(which postman) ]]
    then
        echo ' ----> installing postman ' | tee -a ~/install.log
        brew install --cask postman
    else
        log " --> postman already installed ! " | tee -a ~/install.log
    fi
}

############
## PYTHON 
############
installPYTHON () {

    if [[ -z $(which python) ]]
    then
        echo ' ----> installing python ' | tee -a ~/install.log
        brew install python
    else
        log " --> python already installed." | tee -a ~/install.log
    fi
}

#############
## TERRAFORM 
#############
installTERRAFORM () {

    if [[ -z $(which terraform) ]]
    then
        echo ' ----> installing terraform ' | tee -a ~/install.log
        brew install terraform
    else
        log " --> terraform already installed." | tee -a ~/install.log
    fi
}

########
## ZOOM
########
installZOOM () {
        
    if [[ -z $(which zoom) ]]
    then
        echo ' ----> installing zoom ' | tee -a ~/install.log
        brew install --cask zoom
    else
        log " --> zoom already installed ! " | tee -a ~/install.log
    fi
}


installGITHUB () {
        
    if [[ -z $(which github) ]]
    then
        echo ' ----> installing github '
        brew install --cask github
    else
        log " --> github already installed ! "
    fi
}

installBREW () {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

installs () {
    #installADOBEREADER
    installAPP authy
    installAWSIAMauth
    installAPP drawio
    installDOCKER
    installEKSCTL
    installAPP firefox
    installGH
    installAPP handbrake
    installAPP iterm2
    installJQ
    installKEEPASS
    installKUBECTL
    installHELM
    installMINIKUBE
    installPOSTMAN
    installPYTHON
    installTERRAFORM
    installAPP vlc
    installAPP zoom
    
}

#########
## MAIN 
#########

clear
sleep 5
printf "\r\033[00;35;1m -- > Starting   \033[0m"

if [[ -z $(which brew) ]]
    then
        echo ' ----> installing Homebrew ' | tee -a ~/install.log
        installBREW
    else
        echo  " ----> Commencing installs ! " | tee -a ~/install.log
        sleep 5
        installs
        printf "\r\033[00;35;1m -- > COMPLETE   \033[0m" | tee -a ~/install.log
fi
