#!/bin/bash

cd ~/Documents/GitHub/
mkdir TOOLS
cd TOOLS

echo "  --> alertmanager "
git clone git@github.com:prometheus/alertmanager.git

echo " --> jaeger"
git clone git@github.com:jaegertracing/jaeger.git
