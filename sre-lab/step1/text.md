# Troubleshoot the Cluster

The following namespaces each have a broken deployment. Diagnose and fix as many as you can.

### Beginner
| Namespace | Hint |
|-----------|------|
| `data-store` | Something is preventing the pod from being scheduled |
| `payments` | The pod can't start — check its configuration dependencies |
| `analytics` | The pod keeps crashing immediately after starting |
| `notifications` | The pod can't start — similar to payments but different resource type |

### Intermediate
| Namespace | Hint |
|-----------|------|
| `frontend` | Pods are running but the service isn't routing traffic |
| `checkout` | Pods are running and service has endpoints, but connections are refused |
| `proxy` | A Helm release was deployed with bad configuration |
| `backend-api` | The pod starts but gets killed repeatedly |
| `batch-jobs` | Not all replicas are coming up — but no pod-level errors |
| `search` | Pod is running but shows 0/1 ready — service has no endpoints |
| `compute` | Pod is stuck pending — no node can satisfy the requirements |

### Advanced
| Namespace | Hint |
|-----------|------|
| `discovery` | Pod is running but the application inside can't resolve DNS |
| `logging` | StatefulSet pod won't provision its storage |

## Useful starting points

```bash
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

Good luck!
