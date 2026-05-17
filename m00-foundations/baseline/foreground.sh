#!/bin/bash

echo "Waiting for the Polyphone baseline to finish spinning up..."
echo "(installs local-path-provisioner, metrics-server, k9s; provisions 10 namespaces and the 17-workload fleet)"
echo ""

while [ ! -f /tmp/.setup-complete ]; do
  sleep 3
  echo -n "."
done
echo ""
echo ""
echo "Cluster is ready. Try the first command:"
echo ""
echo "  kubectl get nodes -o wide"
echo ""
