#!/bin/bash
source ./w8.bash
this_cwd=$(pwd)

main () {
  #set -eux
  set -eu
  kind create cluster --config=kind-config.yaml
  kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
  cd $this_cwd
  cd ../
  ./addCharts.sh
  ./openebs.sh
  ./certmanager.sh
  ./argocd.sh
  ./kubegres.sh
  cd $this_cwd
  kubectl apply -f namespace.yaml
  kubectl apply -f openebs-hostpath.yaml

  set +e
  w8_pod kubegres-system kubegres-controller-manager
  kubectl_native_wait kubegres-system $(kubectl get po -n kubegres-system|grep kubegres-controller-manager|cut -f1 -d ' ')
  set -e
  kubectl apply -f argocd-ingress.yaml
  #sleep 3
  set +e
  w8_ingress argocd argocd-server-ingress 

  argocd admin initial-password -n argocd
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

  w8_pod kube-system kube-proxy
  w8_pod openebs openebs-lvm-localpv-controller
  w8_pod local-path-storage local-path-provisioner
  w8_pod cert-manager cert-manager
  w8_pod argocd argocd-server 
  w8_pod argocd argocd-repo-server
  w8_pod ingress-nginx ingress-nginx-controller
  ./up.sh
}

time main

exit 0
kubectl apply -f foobar.yaml
kubectl get pod -A --watch
