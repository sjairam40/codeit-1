#!/bin/bash

cd ~/Documents/GitHub/
mkdir TOOLS
cd TOOLS

echo "  --> alertmanager "
git clone git@github.com:prometheus/alertmanager.git

echo " --> argocd"
git clone git@github.com:argoproj/argo-cd.git

echo " --> jaeger"
git clone git@github.com:jaegertracing/jaeger.git

echo " --> popeye"
git clone git@github.com:derailed/popeye.git

echo " --> samber/prometheus"
git clone git@github.com:samber/awesome-prometheus-alerts.git