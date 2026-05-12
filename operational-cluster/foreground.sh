#!/bin/bash
# Runs in the foreground — trainee sees this output.
# Waits for the background setup to finish before handing control.

echo "Preparing your cluster environment..."
echo ""

while [ ! -f /tmp/.setup-complete ]; do
    sleep 2
done

echo "Environment ready. 8 namespaces deployed, all workloads healthy."
echo ""
echo "Start with:  kubectl get pods -A"
echo ""
