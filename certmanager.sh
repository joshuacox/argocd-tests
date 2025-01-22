#!/bin/sh
set -eux
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.3 \
  --set prometheus.enabled=true \
  --set crds.enabled=true
#kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.crds.yaml
kubectl -n cert-manager get pod
./mkcert.sh
kubectl apply -f cluster-issuer-staging.yaml
kubectl apply -f cluster-issuer-production.yaml
kubectl apply -f cluster-issuer-mkcert.yaml
kubectl get ClusterIssuer -A
kubectl describe clusterissuer letsencrypt-staging
kubectl describe clusterissuer letsencrypt-production
kubectl describe clusterissuer mkcert-issuer 
kubectl create deployment nginx --image nginx:alpine 
kubectl expose deployment nginx --port 80 --target-port 80
kubectl apply -f secrets.yml
#kubectl apply -f ingress-nginx.yaml
kubectl get cert -n default
