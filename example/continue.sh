#!/bin/bash
source ./w8.bash
this_cwd=$(pwd)

main () {
  #set -eux
  set -eu
  ./w8s.sh

  echo 'sometimes github.com fails to resolve if these creates hit too quick'
  echo 'still investigating as to what is causing it'
  echo "run this script ($0) again after a slight rest if this fails"
  sleep 5

  argocd app create -f kube-prometheus-stack/argocd.yaml --name example-prometheus-stack --grpc-web
  argocd app create -f openldap/argocd.yaml --name example-openldap --grpc-web
  argocd app create -f nc/argocd.yaml --name examplenc --grpc-web
  cd bao
  ./openbao.sh
  kubectl apply -f bao/openbaoui-ingress.yaml
}

time main
