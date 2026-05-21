#!/bin/bash

echo "Waiting for the Polyphone baseline + scenario mutation..."
echo ""

while [ ! -f /tmp/.setup-complete ]; do
  sleep 3
  echo -n "."
done
echo ""
echo ""
echo "Cluster is up. Alert fires:"
echo ""
echo "  +-----------------------------------------------+"
echo "  | ALERT: Polyphone fleet -- workload degraded   |"
echo "  | namespace: (not reported)                     |"
echo "  | workload:  (not reported)                     |"
echo "  +-----------------------------------------------+"
echo ""
echo "What's your first command?"
echo ""
