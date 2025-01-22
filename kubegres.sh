#!/bin/sh
kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/v1.18/kubegres.yaml
kubectl apply -f townhall-postgres.yaml
