#!/bin/bash
# Checks: cluster has 2 nodes Ready and kube-system has the required core
# control-plane components. kube-proxy is treated as optional because some
# Kubernetes setups (Killercoda's kubeadm-2nodes among them, or clusters using
# Cilium kube-proxy-replacement) don't run it as a standalone pod.

NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c " Ready ")
[ "$NODES" -ge 2 ] || { echo "Expected 2+ Ready nodes, got $NODES" >&2; exit 1; }

# Required components: each must have at least 1 Running pod in kube-system.
REQUIRED="etcd- kube-apiserver- kube-controller-manager- kube-scheduler- coredns-"
PODS=$(kubectl get pods -n kube-system --no-headers 2>/dev/null)

for COMPONENT in $REQUIRED; do
  COUNT=$(echo "$PODS" | grep -E "^${COMPONENT}" | awk '$3 == "Running"' | wc -l)
  [ "$COUNT" -ge 1 ] || {
    echo "Expected at least 1 Running ${COMPONENT}* pod in kube-system, got $COUNT" >&2
    exit 1
  }
done

TOTAL=$(echo "$PODS" | awk '$3 == "Running"' | wc -l)
echo "✓ Cluster anatomy: $NODES nodes Ready, all required control-plane components present ($TOTAL Running pods in kube-system)"
exit 0
