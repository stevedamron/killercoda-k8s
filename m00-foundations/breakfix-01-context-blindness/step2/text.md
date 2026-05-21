# Step 2 — Fix your context and verify

Two ways to fix this. Pick based on what you actually want:

## Option A: scope to a workload namespace (recommended)

Pick a Polyphone namespace and make it your default. The fleet has 10 named namespaces (`app-services`, `media`, `signaling`, `admin-portal`, `analytics`, etc.) — choose whichever fits the task you're about to do.

```bash
kubectl config set-context --current --namespace=app-services
```{{exec}}

Verify:

```bash
kubectl config view --minify | grep namespace:
```{{exec}}

Should show `namespace: app-services`.

```bash
kubectl get pods
```{{exec}}

You'll see the `app-services` workloads — visible proof the cluster was always healthy; your view was the problem. The same workloads also show up by their `plane` label (from baseline/step2):

```bash
kubectl get pods -l plane=app -A
```{{exec}}

## Option B: clean-slate reset to `default`

If you don't have a specific namespace in mind and just want to stop being scoped to `kube-public`, revert to Kubernetes' conventional default:

```bash
kubectl config set-context --current --namespace=default
```{{exec}}

```bash
kubectl get pods
```{{exec}}

Returns nothing — `default` is empty on this lab (Polyphone workloads all live in named namespaces). But notice the error message now reads `No resources found in default namespace` — your scope is no longer surprising, which is the whole point.

## Confirm the cluster was healthy all along

```bash
kubectl get pods -n app-services
```{{exec}}

You see the workloads — the cluster was never broken. The alert was either stale, misrouted, or your monitoring was pointing at the same misconfigured kubeconfig you were.

For self-grading and the production practices that make this class of incident impossible, see [`ANSWER-KEY.md`](../ANSWER-KEY.md). For the underlying concepts (contexts, kubeconfig, the resource model), see [`LESSON.md`](../LESSON.md).

You're done with breakfix-01. See `finish.md`.
