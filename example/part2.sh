#!/bin/bash
source ./w8.bash
this_cwd=$(pwd)

main () {
  #set -eux
  set -eu
  ./secrets.sh
  kubectl apply -f examplenc-secrets.yaml
  kubectl apply -f postgres.yaml

  ./continue.sh
}

time main
