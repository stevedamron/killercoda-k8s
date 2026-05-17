# Step 2 — Fix it and verify

The image tag is wrong. Restore the working one (`nginx:1.25`).

## Apply the fix

```bash
kubectl set image deployment/metrics-aggregator app=nginx:1.25 -n analytics
```{{exec}}

Or, if you prefer to read and edit the manifest:

```bash
kubectl edit deployment metrics-aggregator -n analytics
# change spec.template.spec.containers[0].image to: nginx:1.25
```

`kubectl set image` is faster for a one-field fix. `kubectl edit` is better when you want to see the full manifest in context.

## Watch the rollout converge

```bash
kubectl rollout status deployment metrics-aggregator -n analytics
```{{exec}}

You should see `deployment "metrics-aggregator" successfully rolled out` within ~30 seconds.

Confirm the pod is healthy:

```bash
kubectl get pods -n analytics
```{{exec}}

You should see one `Running` pod with `1/1 READY`, `0` restarts.

## Confirm the alert would now clear

```bash
kubectl get pods -A --field-selector=status.phase!=Running --no-headers | wc -l
```{{exec}}

The result should be `0` (or only short-lived `Pending` pods that are rolling out). The fleet is back to green.

## What this scenario tested

Three instincts:

- First-command instinct: did you reach for `-A`?
- Diagnostic loop: did you progress `get → events → describe` in order, or did you guess?
- `kubectl set image` vs `kubectl edit`: do you know both and pick the right one?

For the full canonical walkthrough and self-grading questions, see `ANSWER-KEY.md`.

## Production thinking

`kubectl set image` is a bandaid. It works, but the change isn't reflected in your GitOps source of truth. On the next Flux reconciliation the cluster could drift back to the broken state — or worse, your fix gets reverted when an unrelated PR merges.

The production fix:

1. Triage with `kubectl set image` to stop the bleeding.
2. Open a PR to `platform-gitops` correcting the manifest.
3. Let Flux re-apply the corrected manifest, eliminating the out-of-band fix.
4. Post-mortem: how did the bad image tag merge in the first place? Should CI block deployments referencing non-existent images?

You'll meet Flux and the GitOps loop in M11–M14. The principle to carry forward: `kubectl` changes are temporary unless the source of truth agrees.

You're done with breakfix-01. See `finish.md`.
