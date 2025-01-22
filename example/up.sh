#!/bin/bash
source ./w8.sh
source ./w8.bash
this_cwd=$(pwd)

main () {
  set -eux
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
  ./secrets.sh
  kubectl apply -f examplenc-secrets.yaml
  sleep 23
  kubectl_native_wait kubegres-system $(kubectl get po -n kubegres-system|grep kubegres-controller-manager|cut -f1 -d ' ')
  kubectl apply -f postgres.yaml
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
  kubectl apply -f argocd-ingress.yaml
  w8_ingress argocd-server-ingress 
  sleep 3
  kubectl_native_wait example $(kubectl get po -n example|grep examplenc-postgres|cut -f1 -d ' ')
  argocd admin initial-password -n argocd
  PASSWORD_ARGO=$(argocd admin initial-password -n argocd|head -n 1)
  argocd login argocd.example.com --username admin --password ${PASSWORD_ARGO}
}

time main

exit 0
kubectl apply -f foobar.yaml
kubectl get pod -A --watch
