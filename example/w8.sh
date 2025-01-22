#!/bin/sh
kubectl_native_wait () {
  if [[ $# -eq 2 ]]; then
    TARGET_NAMESPACE=$1
    TARGET_POD=$2
    kubectl wait \
      --namespace $TARGET_NAMESPACE \
      --for=condition=ready pod $TARGET_POD \
      --timeout=120s
  else
    echo 'ERROR: wrong number of arguments!'
    echo "$0 NAMESPACE POD"
  fi
}
