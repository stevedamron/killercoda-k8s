# M00 — Break/fix 01: Context Blindness

> Pre-req: completed M00 baseline tour, or comfortable with `kubectl config` basics.

You're on call. An alert fires: **"Polyphone fleet — multiple workloads degraded."** You SSH into the bastion and run:

```bash
kubectl get pods
```

Output:

```text
No resources found in kube-public namespace.
```

Wait. The alert claims workloads are unhealthy. But `kubectl get pods` says there are no pods at all. Did someone delete everything? Did the cluster reboot empty? Did you get paged for the wrong cluster?

**Before you start poking around the cluster, ask whether the cluster is the problem — or whether your view of it is.**

This is the most embarrassing class of incident: spending 20 minutes investigating a cluster that's perfectly fine because your terminal was pointed somewhere unexpected.

The cluster takes 60–120 seconds to come up. Click **Start** when ready.
