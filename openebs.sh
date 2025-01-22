#!/bin/sh
set -eux
helm install openebs --namespace openebs openebs/openebs -f openebs-values.yaml --create-namespace
kubectl apply -f openebs-sc.yaml
