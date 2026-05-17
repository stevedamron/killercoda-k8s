# Step 1 — Cluster anatomy

Every Kubernetes cluster has the same skeleton: a **control plane** that decides what runs, and one or more **nodes** that actually run it. Start by looking at the cluster's own components.

## See the nodes

```bash
kubectl get nodes -o wide
```{{exec}}

You should see two nodes — one with role `control-plane` and one worker. The control-plane node hosts the API server, etcd, the scheduler, and the controller manager. The worker hosts most of the application pods you'll meet in step 2.

## Look at the control plane

The control plane components themselves run as pods in the `kube-system` namespace:

```bash
kubectl get pods -n kube-system
```{{exec}}

You'll see (among others):

| Pod                       | What it does                                                  |
|---------------------------|---------------------------------------------------------------|
| `etcd-*`                  | The cluster's database. Everything lives here.                |
| `kube-apiserver-*`        | The only thing that talks to etcd. Every client talks to this.|
| `kube-controller-manager-*` | Runs the built-in controllers (Deployment, ReplicaSet, etc.) |
| `kube-scheduler-*`        | Decides which node each new pod runs on                       |
| `kube-proxy-*`            | One per node. Programs iptables/IPVS for Services             |
| `coredns-*`               | Cluster DNS. Resolves `<svc>.<ns>.svc.cluster.local`.         |

These are not Polyphone workloads — they are the cluster itself. When the cluster misbehaves, this is the namespace to check first.

## Try the API server directly (optional)

`kubectl` is a thin client. You can hit the same API with `curl` through `kubectl proxy`:

```bash
kubectl proxy --port=8001 &
sleep 1
curl -s http://localhost:8001/api/v1/namespaces | head -20
kill %1
```{{exec}}

You see the raw JSON the API server returns. `kubectl get namespaces` does exactly this and pretty-prints the result.

## Verify

```bash
kubectl get nodes && kubectl get pods -n kube-system --field-selector=status.phase=Running | wc -l
```{{exec}}

You should see 2 nodes Ready and at least ~7 running pods in `kube-system`.

Move on to step 2.
