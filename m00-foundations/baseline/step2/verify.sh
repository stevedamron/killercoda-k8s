#!/bin/bash
# Checks: all 10 Polyphone namespaces exist and the fleet has pods running.
EXPECTED_NS="media signaling app-services edge provisioning admin-portal call-routing cdr-storage analytics number-porting"
MISSING=""
for ns in $EXPECTED_NS; do
  kubectl get ns "$ns" >/dev/null 2>&1 || MISSING="$MISSING $ns"
done
[ -z "$MISSING" ] || { echo "Missing Polyphone namespaces:$MISSING" >&2; exit 1; }

RUNNING=$(kubectl get pods -A --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
[ "$RUNNING" -ge 20 ] || { echo "Expected 20+ Running pods cluster-wide, got $RUNNING" >&2; exit 1; }

echo "✓ Polyphone fleet: 10 namespaces present, $RUNNING pods Running"
exit 0
