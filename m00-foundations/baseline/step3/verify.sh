#!/bin/bash
# Step 3 (kubectl idioms) is a fluency drill — no state change, no breakage.
# We verify the fleet is still healthy (no learner accidentally deleted something)
# and that kubectl can talk to the cluster.
kubectl version --request-timeout=5s >/dev/null 2>&1 || { echo "kubectl can't reach the cluster" >&2; exit 1; }
READY=$(kubectl get pods -n admin-portal -l app=portal-ui --no-headers 2>/dev/null | awk '$3 == "Running"' | wc -l)
[ "$READY" -ge 2 ] || { echo "Expected 2 portal-ui pods Running, got $READY" >&2; exit 1; }

echo "✓ kubectl idioms drill — cluster reachable, portal-ui still healthy ($READY pods Running)"
exit 0
