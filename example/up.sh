#!/bin/bash
./secrets.sh
kubectl apply -f examplenc-secrets.yaml
argocd app create -f openldap/argocd.yaml --name example-openldap --grpc-web
kubectl apply -f postgres.yaml
kubectl apply -f redirect.yaml
sleep 3
source ../w8.sh
kubectl_native_wait $(kubectl get po -n example|grep examplenc-postgres|cut -f1 -d ' ') example
argocd app create -f nc/argocd.yaml --name examplenc --grpc-web
