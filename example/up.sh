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
  ./secrets.sh
  kubectl apply -f examplenc-secrets.yaml
  set +e
  w8_pod kubegres-system kubegres-controller-manager
  kubectl_native_wait kubegres-system $(kubectl get po -n kubegres-system|grep kubegres-controller-manager|cut -f1 -d ' ')
  set -e
  kubectl apply -f postgres.yaml
  set +e
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
  set -e
  kubectl apply -f argocd-ingress.yaml
  #sleep 3
  set +e
  w8_ingress argocd argocd-server-ingress 
  kubectl_native_wait example $(kubectl get po -n example|grep examplenc-postgres|cut -f1 -d ' ')
  set -e
  argocd admin initial-password -n argocd
  PASSWORD_ARGO=$(argocd admin initial-password -n argocd|head -n 1)
  argocd login argocd.example.com \
    --password ${PASSWORD_ARGO} \
    --username admin \
    --grpc-web
  argocd account update-password \
    --current-password ${PASSWORD_ARGO} \
    --new-password  $(yq '.stringData|."argocdadmin-password"' .examplenc-plain-secrets.yaml) \
    --grpc-web
  argocd login argocd.example.com \
    --password  $(yq '.stringData|."argocdadmin-password"' .examplenc-plain-secrets.yaml) \
    --username admin \
    --grpc-web
  argocd app create -f openldap/argocd.yaml --name example-openldap --grpc-web
  argocd app create -f nc/argocd.yaml --name examplenc --grpc-web
}

time main

exit 0
kubectl apply -f foobar.yaml
kubectl get pod -A --watch
