# Step 1 — Diagnose your view

Before assuming the cluster is broken, take 10 seconds to confirm where you're looking.

## Try first: pivot to cluster-wide

```bash
kubectl get pods -A
```{{exec}}

The cluster has plenty of pods running across the Polyphone namespaces, `kube-system`, `local-path-storage`, and others. The cluster is fine.

So why did `kubectl get pods` return nothing? Read the error message again:

```text
No resources found in kube-public namespace.
```

`kubectl` is scoping the query to `kube-public`. That namespace has no Polyphone workloads (Kubernetes uses it for cluster-info ConfigMaps, nothing else). The cluster isn't broken — your default namespace is set wrong.

## Confirm where you are

```bash
kubectl config current-context
```{{exec}}

This tells you which **cluster + user + namespace** combo `kubectl` is pointed at.

```bash
kubectl config view --minify
```{{exec}}

`--minify` shows only the active context's details. Look at the `namespace:` line under `context:`. You'll see `namespace: kube-public`.

```bash
kubectl config get-contexts
```{{exec}}

The column `NAMESPACE` shows the default namespace for each context. The active one (marked with `*`) is `kube-public`.

The cluster is fine. The **kubeconfig** (`~/.kube/config` — the file `kubectl` reads to know which cluster, which credentials, and what default namespace to use) says "by default, scope every query to `kube-public`". That's why your unscoped `kubectl get pods` returned nothing.

## Why this matters

This is the most common false-alarm in a multi-cluster shop. Someone:

- Switched namespaces with `kubens` and forgot to switch back
- Ran a command earlier with `kubectl config set-context --current --namespace=...` and didn't reset
- Was handed a kubeconfig pre-scoped to an unusual namespace
- Is on the wrong cluster entirely (different `current-context`)

The fix is trivial. The instinct — **suspect your own setup before the cluster** — is the lesson. Move to step 2.
