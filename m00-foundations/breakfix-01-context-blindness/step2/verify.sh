#!/bin/bash
# Checks: metrics-aggregator image is restored to nginx:1.25 and at least one pod is Running.
IMAGE=$(kubectl get deployment metrics-aggregator -n analytics -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
[ "$IMAGE" = "nginx:1.25" ] || { echo "Deployment image is '$IMAGE', expected 'nginx:1.25'" >&2; exit 1; }

RUNNING=$(kubectl get pods -n analytics -l app=metrics-aggregator --no-headers 2>/dev/null | awk '$3 == "Running"' | wc -l)
[ "$RUNNING" -ge 1 ] || { echo "Expected 1+ Running pod, got $RUNNING (image fix may still be rolling out)" >&2; exit 1; }

echo "✓ Fix applied: image=$IMAGE, $RUNNING pod(s) Running"
exit 0
