#!/bin/bash
source ./w8.sh
this_cwd=$(pwd)
set -eux
kind create cluster --config=kind-config.yaml
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
sleep 3
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
cd $this_cwd
cd ../
./openebs.sh
./certmanager.sh
./argocd.sh
./kubegres.sh
cd $this_cwd
kubectl apply -f namespace.yaml
./secrets.sh
sleep 3
kubectl apply -f examplenc-secrets.yaml
kubectl_native_wait kubegres-system kubegres-controller-manager
kubectl apply -f argocd-ingress.yaml
kubectl apply -f postgres.yaml
sleep 3
kubectl_native_wait example $(kubectl get po -n example|grep examplenc-postgres|cut -f1 -d ' ')
argocd admin initial-password -n argocd

exit 0
kubectl apply -f foobar.yaml
kubectl get pod -A --watch
