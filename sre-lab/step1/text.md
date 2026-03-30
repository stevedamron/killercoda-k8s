# Troubleshoot the Cluster

The following namespaces each have a broken deployment. Diagnose and fix as many as you can.

| Namespace | Hint |
|-----------|------|
| `ns-storage` | Something is preventing the pod from being scheduled |
| `ns-secrets` | The pod can't start — check its configuration |
| `ns-resources` | The pod keeps crashing |
| `ns-networking` | Pods are running but the service isn't working |
| `ns-helm` | A Helm release was deployed with bad configuration |
| `ns-probe` | The pod starts but gets killed repeatedly |

## Useful starting points

```bash
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

Good luck!
