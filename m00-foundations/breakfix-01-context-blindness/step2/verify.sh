#!/bin/bash
# Checks: current kubeconfig default namespace is now a Polyphone workload
# namespace, not the broken `default` scope. The broken state is namespace
# explicitly set to "default" (or unset, which K8s resolves to "default").
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}' 2>/dev/null)
if [ -z "$CURRENT_NS" ] || [ "$CURRENT_NS" = "default" ]; then
  echo "Default namespace is still 'default' (or unset). Set to a Polyphone workload namespace, e.g.:" >&2
  echo "  kubectl config set-context --current --namespace=app-services" >&2
  exit 1
fi

echo "✓ Default namespace corrected: $CURRENT_NS"
exit 0
