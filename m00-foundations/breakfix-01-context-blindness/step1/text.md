# Step 1 — Diagnose your view

Before assuming the cluster is broken, take 10 seconds to confirm where you're looking.

## Try first: pivot to cluster-wide

```bash
kubectl get pods -A
```{{exec}}

The cluster has plenty of pods running across the Polyphone namespaces, `kube-system`, `local-path-storage`, and others. The cluster is fine.

So why did `kubectl get pods` return nothing? Read the error message again:

```text
No resources found in default namespace.
```

`kubectl` is scoping the query to `default` — but Polyphone workloads all live in named namespaces (`app-services`, `media`, `signaling`, etc.); `default` is empty. The cluster isn't broken — your default namespace is set wrong.

## Confirm where you are

```bash
kubectl config current-context
```{{exec}}

This tells you which **cluster + user + namespace** combo `kubectl` is pointed at.

```bash
kubectl config view --minify
```{{exec}}

`--minify` shows only the active context's details. Look at the `namespace:` line under `context:`. You'll see `namespace: default`.

```bash
kubectl config get-contexts
```{{exec}}

The `NAMESPACE` column shows the default namespace for each context. The active one (marked with `*`) is `default`.

The cluster is fine. The **kubeconfig** (`~/.kube/config` — the file `kubectl` reads to know which cluster, which credentials, and what default namespace to use) is scoping every query to `default`, where Polyphone has nothing.

The instinct to build: **suspect your own setup before the cluster.** Move to step 2.
