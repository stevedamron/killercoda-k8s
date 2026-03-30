#!/bin/bash
# Runs in the foreground — candidate sees this output.
# Waits for the background setup to finish before handing control.

echo "Preparing your cluster environment..."
echo ""

while [ ! -f /tmp/.setup-complete ]; do
    sleep 2
done

echo "Environment ready! You have 6 namespaces to troubleshoot."
echo ""
echo "Start with:  kubectl get pods -A"
echo ""
