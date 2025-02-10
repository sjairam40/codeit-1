#!/bin/bash

cd ~/Documents/GitHub/
mkdir PERS
cd PERS

echo "  --> aws docker "
git clone git@github.com:sjairam/aws-docker-githubActons-kubernetes-demo.git 

echo " --> ci-cd intro"
git clone https://github.com/Link-/ci-cd-intro

echo " --> codeit "
git clone git@github.com:sjairam/codeit.git

echo " --> demo "
git clone git@github.com:sjairam/demo-container-gh-actions.git

echo " --> k8s coursee"
git clone https://gitlab.com/twn-cka-course/latest/k8s-administrator-course

echo " --> terraform github actions"
git clone git@github.com:sjairam/terraform-github-actions-aws.git