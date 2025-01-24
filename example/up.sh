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
  sleep 3
  set -x
  w8_ingress argocd argocd-server-ingress 
  sleep 5

  ./argocd-init-pass.sh

  ./part2.sh
}

time main

exit 0

kubectl get pod -A
kubectl get ingress -A
kubectl apply -f foobar.yaml
kubectl get pod -A --watch
