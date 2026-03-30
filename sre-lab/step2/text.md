# Incident: Multiple Services Degraded

You just got paged. Monitoring shows several services across the platform are unhealthy. Your job is to **triage and resolve as many as you can**.

Work in whatever order makes sense to you. Start broad, then drill in.

---

### Beginner
| Namespace | Service | Alert |
|-----------|---------|-------|
| `provisioning` | Account Provisioner | Pod can't start — container config error |
| `call-analytics` | Metrics Aggregator | Pod keeps crashing immediately after starting |
| `cdr-storage` | CDR Writer | Pod stuck pending — can't schedule |

### Intermediate
| Namespace | Service | Alert |
|-----------|---------|-------|
| `admin-portal` | Portal UI | Pods running but service is unreachable |
| `call-routing` | Route Engine | Pods running, service has endpoints, but connections refused |
| `number-porting` | Port Processor | Not all replicas coming up — no pod-level errors |
| `media-processing` | Transcoder | Pod stuck pending — scheduling failure |

### Advanced
| Namespace | Service | Alert |
|-----------|---------|-------|
| `service-mesh` | Consul Agent | Pod running but application can't resolve upstream services |

## Useful starting points

```bash
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
```
