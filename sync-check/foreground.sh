#!/bin/bash

echo "Preparing your cluster environment..."
echo ""

while [ ! -f /tmp/.setup-complete ]; do
    sleep 2
done

echo "Environment ready. 3 namespaces deployed: voice-gateway, sms-router, billing-events"
echo ""
echo "Try:  kubectl get pods -A"
echo ""
