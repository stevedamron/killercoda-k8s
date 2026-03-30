# Troubleshoot the Cluster

You've inherited a communications platform cluster with multiple broken services. Diagnose and fix as many as you can. You may use any tools available to you, including AI assistants.

### Beginner
| Namespace | Service | Hint |
|-----------|---------|------|
| `provisioning` | Account Provisioner | The pod can't start — check its configuration dependencies |
| `call-analytics` | Metrics Aggregator | The pod keeps crashing immediately after starting |
| `cdr-storage` | CDR Writer | Something is preventing the pod from being scheduled |

### Intermediate
| Namespace | Service | Hint |
|-----------|---------|------|
| `admin-portal` | Portal UI | Pods are running but the service isn't routing traffic |
| `call-routing` | Route Engine | Pods are running and service has endpoints, but connections are refused |
| `number-porting` | Port Processor | Not all replicas are coming up — but no pod-level errors |
| `media-processing` | Transcoder | Pod is stuck pending — no node can satisfy the requirements |

### Advanced
| Namespace | Service | Hint |
|-----------|---------|------|
| `service-mesh` | Consul Agent | Pod is running but the application inside can't resolve DNS |

## Available tools

- `kubectl` / `k` (aliased)
- `k9s` — terminal UI for Kubernetes
- `helm`
- AI assistants (if available)

## Useful starting points

```bash
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
k9s
```

Good luck!
