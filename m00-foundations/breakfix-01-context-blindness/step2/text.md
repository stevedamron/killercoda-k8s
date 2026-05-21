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

## Confirm the alert was a false signal

The cluster was healthy the whole time. Sanity-check fleet-wide:

```bash
kubectl get pods -A -l plane --field-selector=status.phase!=Running --no-headers | wc -l
```{{exec}}

Should be `0`. We scope with `-l plane` to count only Polyphone workloads — a bare `-A` also catches cluster-service helpers (e.g., `local-path-provisioner`) that legitimately sit in `Succeeded` phase. Fleet is green; the alert was either stale, misrouted, or your monitoring was pointing at the same misconfigured kubeconfig you were. (In a real shop, the *alert* is now the bug — investigate why it fired against a healthy cluster.)

## What this scenario tested

Three instincts:

- Did you check `kubectl get pods -A` BEFORE assuming the cluster was broken? That single command would have shown the cluster is fully populated.
- Did you read the error message carefully? `"No resources found in kube-public namespace"` literally told you the namespace was scoped wrong.
- Do you know the difference between `current-context` (which cluster) and the namespace within a context (which default scope)?

For the full canonical walkthrough and self-grading, see `ANSWER-KEY.md`.

## Production thinking

Three operational practices that make this class of incident impossible:

1. **Shell prompt customization.** Make your terminal show `<context>:<namespace>` at all times. Tools like [kube-ps1](https://github.com/jonmosco/kube-ps1) or oh-my-zsh's kubectl plugin do this. If you can see "prod-us-east-1:kube-public" in your prompt, you'll never get surprised.
2. **Separate terminals per environment.** Don't share a terminal between `prod` and `lab`. Use different windows, different colors, different tmux sessions. Make context-switching require deliberate action.
3. **Read-only contexts for `prod` by default.** Use a kubeconfig that maps `prod` to a read-only user. Switch to a write-capable context as a separate, deliberate action. Cuts wrong-cluster mutations to near-zero.

You're done with breakfix-01. See `finish.md`.
