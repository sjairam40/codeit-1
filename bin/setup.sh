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

#log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }        # $1 uppercase background white
#info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }      # $1 uppercase background green
#warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background orange
#error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background red


###############
## Create Env
###############

create-env() {
    # log install site npm modules
    cd "$dir/site"
    npm install

    [[ -f "$dir/.env" ]] && { log skip .env file already exists; return; }
    info create .env file

    # check if user already exists (return something if user exists, otherwise return nothing)
    local exists=$(aws iam list-user-policies \
        --user-name $PROJECT_NAME \
        --profile $AWS_PROFILE \
        2>/dev/null)
        
    [[ -n "$exists" ]] && { error abort user $PROJECT_NAME already exists; return; }

    # create a user named $PROJECT_NAME
    log 'create iam user '+$PROJECT_NAME
    aws iam create-user \
        --user-name $PROJECT_NAME \
        --profile $AWS_PROFILE \
        1>/dev/null

    aws iam attach-user-policy \
        --user-name $PROJECT_NAME \
        --policy-arn arn:aws:iam::aws:policy/PowerUserAccess \
        --profile $AWS_PROFILE

    local key=$(aws iam create-access-key \
        --user-name $PROJECT_NAME \
        --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' \
        --profile $AWS_PROFILE \
        2>/dev/null)

    local AWS_ACCESS_KEY_ID=$(echo "$key" | jq '.AccessKeyId' --raw-output)
    log 'AWS_ACCESS_KEY_ID' + $AWS_ACCESS_KEY_ID
    
    local AWS_SECRET_ACCESS_KEY=$(echo "$key" | jq '.SecretAccessKey' --raw-output)
    log 'AWS_SECRET_ACCESS_KEY' + $AWS_SECRET_ACCESS_KEY

    # create ECR repository
    local repo=$(aws ecr describe-repositories \
        --repository-names $PROJECT_NAME \
        --region $AWS_REGION \
        --profile $AWS_PROFILE \
        2>/dev/null)
    if [[ -z "$repo" ]]
    then
        log 'ecr create-repository'+ $PROJECT_NAME
        local ECR_REPOSITORY=$(aws ecr create-repository \
            --repository-name $PROJECT_NAME \
            --region $AWS_REGION \
            --profile $AWS_PROFILE \
            --query 'repository.repositoryUri' \
            --output text)
        log 'ECR_REPOSITORY '+ $ECR_REPOSITORY
    fi

    # envsubst tips : https://unix.stackexchange.com/a/294400
    # create .env file
    cd "$dir"
    # export variables for envsubst
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export ECR_REPOSITORY
    envsubst < .env.tmpl > .env

    info created file .env
}

###########
## yq
###########
# install yq if missing (no update)
install-yq() {
    if [[ -z $(which yq) ]]
    then
        log 'install yq'
        warn warn sudo is required
        cd /usr/local/bin
        sudo curl "https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64" \
            --progress-bar \
            --location \
            --output yq
        sudo chmod +x yq
    else
        log 'skip yq already installed'
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

###########
## AWS IAM 
###########
installAWSIAMauth () {

    if [[ -z $(which aws-iam-authenticator) ]]
    then
        echo ' ----> installing aws-iam-authenticator '
        brew install aws-iam-authenticator
    else 
        log " --> aws-iam-authenticator already installed"
    fi
}

##########
## DOCKER 
##########
installDOCKER () {
        
    if [[ -z $(which docker) ]]
    then
        echo ' ----> installing docker '
        brew install --cask docker
    else
        log " --> docker already installed ! "
    fi
}

##########
## EKSCTL 
##########
installEKSCTL () {

    if [[ -z $(which eksctl) ]]
    then
        echo ' ----> installing eksctl  '
        brew install eksctl 
    else 
        log " --> eksctl already installed"
    fi
}

##########
## GH  
##########
installGH () {

    if [[ -z $(which gh) ]]
    then
        echo ' ----> installing gh '
        brew install gh
    else
        log " --> gh already installed."
    fi
}

##########
## HELM
##########
installHELM () {

    if [[ -z $(which helm) ]]
    then
        echo ' ----> installing helm '
        brew install helm
    else
        log " --> helm already installed."
    fi
}

##########
## JQ  
##########
installJQ () {

    if [[ -z $(which jq) ]]
    then
        echo ' ----> installing jq '
        brew install jq
    else
        log " --> jq already installed."
    fi
}

#############
## KEEPASSXC
#############
installKEEPASS() {
    # brew install --cask keepassxc
    if [[ -z $(which keepassxc) ]]
    then
        echo ' ----> installing keepassxc '
        brew install --cask keepassxc
    else
        log " --> keepassxc already installed."
    fi
}

###########
## KUBECTL  
###########
installKUBECTL () {

    if [[ -z $(which kubectl) ]]
    then
        echo ' ----> installing kubectl '
        brew install kubectl
    else
        log " --> kubectl already installed."
    fi
}

############
## MINKUBE 
############
installMINIKUBE ()
{
    brew install hyperkit

    if [[ -z $(which minikube) ]]
    then
        brew install minikube
    else
        log " --> minikube already installed."
    fi

}

############
## PYTHON 
############
installPYTHON () {

    if [[ -z $(which python) ]]
    then
        echo ' ----> installing python '
        brew install python
    else
        log " --> python already installed."
    fi
}

############
## TERRAFORM 
############
installTERRAFORM () {

    if [[ -z $(which terraform) ]]
    then
        echo ' ----> installing terraform '
        brew install terraform
    else
        log " --> terraform already installed."
    fi
}

installBREW () {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

########
## ZOOM
########
installZOOM () {
        
    if [[ -z $(which zoom) ]]
    then
        echo ' ----> installing zoom '
        brew install --cask zoom
    else
        log " --> zoom already installed ! "
    fi
}


installs () {
    installAWSIAMauth
    installDOCKER
    installEKSCTL
    installGH
    installJQ
    installKEEPASS
    installKUBECTL
    installHELM
    installMINIKUBE
    installPYTHON
    installTERRAFORM
    installZOOM
}


#########
## MAIN 
#########

clear
sleep 5
echo ' -- > Starting '

if [[ -z $(which brew) ]]
    then
        echo ' ----> installing Homebrew '
        installBREW
    else
        echo  " --> commencing installs ! "
        installs
fi
