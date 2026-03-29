#!/bin/bash
# Background script — runs automatically when the scenario starts.
# Deploys all broken scenarios into the cluster.
# Candidate does NOT see this script running.

echo "Waiting for Kubernetes cluster to be ready..."
while ! kubectl get nodes 2>/dev/null | grep -q " Ready"; do
    sleep 2
done

echo "Cluster ready. Deploying scenarios..."

# Apply all manifests
for f in /tmp/scenarios/*.yaml; do
    kubectl apply -f "$f" 2>/dev/null
done

# Run Helm scenario
bash /tmp/scenarios/ns-helm-install.sh 2>/dev/null

# Wait for pods to attempt scheduling
sleep 10

echo "Scenarios deployed."
