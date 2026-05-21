#!/bin/bash

echo "Waiting for the Polyphone baseline + scenario state..."
echo ""

while [ ! -f /tmp/.setup-complete ]; do
  sleep 3
  echo -n "."
done
echo ""
echo ""
echo "Cluster is up. Alert fires:"
echo ""
echo "  +-----------------------------------------------------+"
echo "  | ALERT: port-processor (number-porting) degraded     |"
echo "  | desired=3  available=2  unavailable=1               |"
echo "  | no pod-level errors reported                        |"
echo "  +-----------------------------------------------------+"
echo ""
echo "Start with:  kubectl get deploy -n number-porting"
echo ""
