#!/bin/bash
# Deploys a Helm release with a bad image tag.
kubectl apply -f /tmp/scenarios/ns-helm-namespace.yaml 2>/dev/null

helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null
helm repo update 2>/dev/null

helm upgrade --install broken-nginx bitnami/nginx \
    --namespace ns-helm \
    --set image.tag=99.99.99-doesnotexist \
    --wait=false 2>/dev/null
