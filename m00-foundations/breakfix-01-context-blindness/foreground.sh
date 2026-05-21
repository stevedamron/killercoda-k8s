#!/bin/bash

echo "Waiting for the Polyphone baseline to finish spinning up..."
echo ""

while [ ! -f /tmp/.setup-complete ]; do
  sleep 3
  echo -n "."
done
echo ""
echo ""
echo "Cluster is up. You're paged:"
echo ""
echo "  +-----------------------------------------------------+"
echo "  | ALERT: Polyphone fleet -- multiple workloads        |"
echo "  | degraded across namespaces                          |"
echo "  +-----------------------------------------------------+"
echo ""
echo "You run:"
echo "  $ kubectl get pods"
echo "  No resources found in default namespace."
echo ""
echo "Is the cluster broken? Or is something else going on?"
echo ""
