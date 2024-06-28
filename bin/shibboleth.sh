#!/bin/bash

kubectl apply -f authconfigs.management.cattle.io\#v3/shibboleth.json

kubectl apply -f users.management.cattle.io\#v3/.

kubectl apply -f userattributes.management.cattle.io\#v3/.

kubectl apply -f secrets.\#v1/cattle-global-data/shibbolethconfig-spkey.json
