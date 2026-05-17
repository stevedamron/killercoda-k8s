#!/bin/bash
# Checks: cluster has 2 nodes Ready and kube-system has core control-plane pods.
NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c " Ready ")
[ "$NODES" -ge 2 ] || { echo "Expected 2+ Ready nodes, got $NODES" >&2; exit 1; }

# kube-system should have at least these running: etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kube-proxy, coredns
CORE=$(kubectl get pods -n kube-system --no-headers 2>/dev/null \
  | grep -E "etcd-|kube-apiserver-|kube-controller-manager-|kube-scheduler-|kube-proxy-|coredns-" \
  | awk '$3 == "Running"' \
  | wc -l)
[ "$CORE" -ge 7 ] || { echo "Expected 7+ running control-plane pods in kube-system, got $CORE" >&2; exit 1; }

echo "✓ Cluster anatomy: $NODES nodes Ready, $CORE core control-plane pods Running"
exit 0
