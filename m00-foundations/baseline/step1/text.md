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
| `coredns-*`               | Cluster DNS. Resolves `<svc>.<ns>.svc.cluster.local`.         |
| `kube-proxy-*` *(optional)* | One per node. Programs iptables/IPVS rules for Services (the cluster's stable virtual IPs that load-balance to Pods). Some setups (e.g. Cilium with kube-proxy replacement) skip it. |

These are not Polyphone workloads — they are the cluster itself. When the cluster misbehaves, this is the namespace to check first.

## Try the API server directly (optional)

`kubectl` is a thin REST client. You can ask it to skip the formatting and dump the raw API response:

```bash
kubectl get --raw /api/v1/namespaces | head -20
```{{exec}}

That JSON is what the API server actually returns over HTTPS on port 6443 — `kubectl get namespaces` does exactly the same request, then pretty-prints the result. Every kubectl command is one of these REST calls under the hood; the magic is in the client, not the wire protocol.

## Verify

```bash
kubectl get nodes && kubectl get pods -n kube-system --field-selector=status.phase=Running | wc -l
```{{exec}}

You should see 2 nodes Ready and ~6 running pods in `kube-system` (etcd, kube-apiserver, kube-controller-manager, kube-scheduler, and 2× coredns at minimum — plus kube-proxy DaemonSet pods if your setup uses it).

Move on to step 2.
