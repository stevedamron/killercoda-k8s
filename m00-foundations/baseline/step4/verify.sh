#!/bin/bash
# Step 4 (JSON unpacking) is a read-only fluency drill.
# Verify the cluster is still healthy and that the JSON tooling available in
# this lab (kubectl jsonpath + jq) actually works.
kubectl version --request-timeout=5s >/dev/null 2>&1 || { echo "kubectl can't reach the cluster" >&2; exit 1; }

# kubectl jsonpath works
IMG=$(kubectl get deployment portal-ui -n admin-portal -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ -n "$IMG" ] || { echo "kubectl jsonpath query failed (could not read portal-ui image)" >&2; exit 1; }

# jq is installed
command -v jq >/dev/null 2>&1 || { echo "jq is not installed — expected for this lab" >&2; exit 1; }

# jq can parse kubectl json output
COUNT=$(kubectl get pods -A -o json 2>/dev/null | jq -r '.items | length')
[ "$COUNT" -gt 0 ] || { echo "jq parse of kubectl output failed" >&2; exit 1; }

echo "✓ JSON tooling works — portal-ui image: $IMG, $COUNT total pods cluster-wide"
exit 0
