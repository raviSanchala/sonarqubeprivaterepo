#!/bin/bash

env=$1 # specify environment

if [[ "$env" =~ ^(dev|uat|prod)$ ]]; then
    kubectl apply -f ./kubernetes/$env-manifest/service-account.yaml
    kubectl apply -f ./kubernetes/$env-manifest/role.yaml
    kubectl apply -f ./kubernetes/$env-manifest/rolebinding.yaml
else
    printf '%s\n' "Environment must be of value dev or prod, got '$env'" >&2
fi
