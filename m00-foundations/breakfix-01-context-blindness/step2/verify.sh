#!/bin/bash
# Checks: current kubeconfig default namespace is no longer kube-public.
# Accepts any value other than kube-public (default, admin-portal, etc.).
CURRENT_NS=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}' 2>/dev/null)
[ "$CURRENT_NS" != "kube-public" ] || { echo "Default namespace is still 'kube-public'. Set to anything else (e.g., 'default')." >&2; exit 1; }

# If unset, also accept (means context-level default = "default" namespace)
DISPLAY="${CURRENT_NS:-default}"
echo "✓ Default namespace corrected: $DISPLAY"
exit 0
