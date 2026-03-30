# Troubleshoot the Cluster

You've inherited a communications platform cluster with multiple broken services. Diagnose and fix as many as you can.

### Beginner
| Namespace | Service | Hint |
|-----------|---------|------|
| `cdr-storage` | CDR Writer | Something is preventing the pod from being scheduled |
| `provisioning` | Account Provisioner | The pod can't start — check its configuration dependencies |
| `call-analytics` | Metrics Aggregator | The pod keeps crashing immediately after starting |
| `alerting` | Alert Dispatcher | The pod can't start — similar to provisioning but different resource type |

### Intermediate
| Namespace | Service | Hint |
|-----------|---------|------|
| `admin-portal` | Portal UI | Pods are running but the service isn't routing traffic |
| `call-routing` | Route Engine | Pods are running and service has endpoints, but connections are refused |
| `sbc-proxy` | Edge Proxy | A Helm release was deployed with bad configuration |
| `registration` | Reg Service | The pod starts but gets killed repeatedly |
| `number-porting` | Port Processor | Not all replicas are coming up — but no pod-level errors |
| `directory` | Lookup Service | Pod is running but shows 0/1 ready — service has no endpoints |
| `media-processing` | Transcoder | Pod is stuck pending — no node can satisfy the requirements |

### Advanced
| Namespace | Service | Hint |
|-----------|---------|------|
| `service-mesh` | Consul Agent | Pod is running but the application inside can't resolve DNS |
| `call-recording` | Recording Writer | StatefulSet pod won't provision its storage |

## Useful starting points

```bash
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

Good luck!
