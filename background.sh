#!/bin/bash
# Runs in the background while the intro page is displayed.
# Candidate does NOT see this output.

# Wait for cluster to be fully ready
echo "Waiting for Kubernetes nodes to be Ready..."
while ! kubectl get nodes 2>/dev/null | grep -q " Ready"; do
    sleep 2
done
sleep 5

echo "Deploying broken scenarios..."

# Apply all YAML manifests
for f in /tmp/scenarios/*.yaml; do
    kubectl apply -f "$f" 2>/dev/null
done

# Run Helm scenario
bash /tmp/scenarios/ns-helm-install.sh 2>/dev/null

# Wait for pods to attempt scheduling
sleep 10

# Signal to foreground that setup is done
touch /tmp/.setup-complete
echo "Setup complete."
