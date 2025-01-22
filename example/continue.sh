#!/bin/bash
this_cwd=$(pwd)
#cd $this_cwd
set -eux

main () {
  argocd app create -f openldap/argocd.yaml --name example-openldap --grpc-web
  argocd app create -f nc/argocd.yaml --name examplenc --grpc-web
}
time main
