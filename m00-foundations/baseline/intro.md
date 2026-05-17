# M00 — Baseline Tour

Welcome to Polyphone, a fictional real-time communications SaaS. You're a new SRE on the platform team and your first job is to *orient yourself* — understand how the cluster is laid out, what workloads live on it, and how to ask it questions.

This scenario uses a healthy, fully-functional cluster running the complete Polyphone fleet:

- **10 namespaces**, **~17 workloads**, organized by architectural plane
- Real Kubernetes object types: Deployments, StatefulSets, DaemonSets, Services, PVCs
- Configured with the same labels and naming conventions every later module will use

There is nothing to fix here. The point is to *see*. Three short steps:

1. **Cluster anatomy** — what's running in `kube-system` and what each piece does
2. **The Polyphone fleet** — tour the namespaces and workloads you'll spend the curriculum operating
3. **The diagnostic loop** — practice the four-command pattern (`get` → `describe` → `events` → `logs`) against a healthy workload, so you'll know what "healthy" looks like before later modules show you what "broken" looks like

The cluster takes 60–120 seconds to fully come up. Click **Start** when ready.
