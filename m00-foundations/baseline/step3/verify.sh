#!/bin/bash
# Checks: portal-ui (the diagnostic-loop walkthrough target) is healthy.
READY=$(kubectl get pods -n admin-portal -l app=portal-ui --no-headers 2>/dev/null | awk '$3 == "Running"' | wc -l)
[ "$READY" -ge 2 ] || { echo "Expected 2 portal-ui pods Running, got $READY" >&2; exit 1; }

echo "✓ portal-ui is healthy ($READY pods Running) — your reference for the diagnostic loop"
exit 0
