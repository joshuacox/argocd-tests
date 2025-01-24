#!/bin/bash
source ./w8.bash
this_cwd=$(pwd)

main () {
  #set -eux
  set -eu
  countzero=0
  result=1
  while [[ ! $result -eq 0 ]]; do
    argocd admin initial-password -n argocd
    result=$?
    if [[ $countzero -gt 9 ]]; then
      break
    fi
  done
  PASSWORD_ARGO=$(argocd admin initial-password -n argocd|head -n 1)

  argocd login argocd.example.com \
    --password ${PASSWORD_ARGO} \
    --username admin \
    --grpc-web

  admin_pass=$(yq '.stringData|."argocdadmin-password"' .examplenc-plain-secrets.yaml|sed 's/"//g')
  admin_pass=${admin_pass//$'\n'/}

  argocd account update-password \
    --current-password ${PASSWORD_ARGO} \
    --new-password  ${admin_pass} \
    --grpc-web

  argocd login argocd.example.com \
    --password  ${admin_pass} \
    --username admin \
    --grpc-web
}

time main
