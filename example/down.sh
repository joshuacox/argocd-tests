#!/bin/bash
kubectl delete -f postgres.yaml
yes y|argocd app delete examplenc --grpc-web
yes y|argocd app delete example-openldap --grpc-web
kubectl delete -f redirect.yaml
kubectl delete -f examplenc-secrets.yaml
sleep 3
kubectl delete -n example pvc examplenc-nextcloud-nextcloud
kubectl delete -n example pvc examplenc-nextcloud-nextcloud-data
kubectl delete -n example pvc postgres-db-examplenc-postgres-1-0
