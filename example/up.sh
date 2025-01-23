#!/bin/bash
source ./w8.bash
this_cwd=$(pwd)

main () {
  #set -eux
  set -eu
  ./secrets.sh
  kubectl apply -f examplenc-secrets.yaml
  kubectl apply -f postgres.yaml
  set +e
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
  set -e
  #sleep 3
  set +e
  kubectl_native_wait example $(kubectl get po -n example|grep examplenc-postgres|cut -f1 -d ' ')
  set -e

  w8_pod kube-system kube-proxy
  w8_pod openebs openebs-lvm-localpv-controller
  w8_pod local-path-storage local-path-provisioner
  w8_pod cert-manager cert-manager
  w8_pod argocd argocd-server 
  w8_pod argocd argocd-repo-server
  w8_pod ingress-nginx ingress-nginx-controller

  echo 'sometimes github.com fails to resolve if these creates hit too quick'
  echo 'still investigating as to what is causing it'
  echo 'use ./continue.sh if this fails'
  sleep 5

  argocd app create -f openldap/argocd.yaml --name example-openldap --grpc-web
  argocd app create -f nc/argocd.yaml --name examplenc --grpc-web
  cd bao
  ./openbao.sh
}

time main

exit 0
kubectl apply -f foobar.yaml
kubectl get pod -A --watch
