#!/bin/bash
# Checks: port-processor Deployment is satisfied (availableReplicas == spec.replicas).
# Accepts either fix path: raise quota OR reduce replicas.
DESIRED=$(kubectl get deployment port-processor -n number-porting -o jsonpath='{.spec.replicas}' 2>/dev/null)
AVAILABLE=$(kubectl get deployment port-processor -n number-porting -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
[ -n "$DESIRED" ] || { echo "Deployment port-processor not found in number-porting" >&2; exit 1; }
[ "$AVAILABLE" = "$DESIRED" ] || { echo "Deployment not satisfied: desired=$DESIRED available=${AVAILABLE:-0}" >&2; exit 1; }

echo "✓ port-processor satisfied: $AVAILABLE/$DESIRED replicas Running"
exit 0
