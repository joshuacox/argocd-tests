#!/bin/bash
set -eux
helm repo add jetstack https://charts.jetstack.io
helm repo add openebs https://openebs.github.io/openebs
helm repo update
