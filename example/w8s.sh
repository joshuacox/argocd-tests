#!/bin/bash
source ./w8.bash

main () {
  set +e
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
  kubectl_native_wait example $(kubectl get po -n example|grep examplenc-postgres|cut -f1 -d ' ')
  set -e

  w8_pod kube-system kube-proxy
  w8_pod openebs openebs-lvm-localpv-controller
  w8_pod local-path-storage local-path-provisioner
  w8_pod cert-manager cert-manager
  w8_pod argocd argocd-server 
  w8_pod argocd argocd-repo-server
  w8_pod ingress-nginx ingress-nginx-controller
}

time main
