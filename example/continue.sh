#!/bin/bash
source ./w8.bash
this_cwd=$(pwd)

main () {
  #set -eux
  set -eu
  w8_pod kube-system kube-proxy
  w8_pod openebs openebs-lvm-localpv-controller
  w8_pod local-path-storage local-path-provisioner
  w8_pod cert-manager cert-manager
  w8_pod argocd argocd-server 
  w8_pod argocd argocd-repo-server
  w8_pod ingress-nginx ingress-nginx-controller

  kubectl get po -A
  argocd app create -f openldap/argocd.yaml --name example-openldap --grpc-web
  argocd app create -f nc/argocd.yaml --name examplenc --grpc-web
}

time main

exit 0
kubectl apply -f foobar.yaml
kubectl get pod -A --watch
