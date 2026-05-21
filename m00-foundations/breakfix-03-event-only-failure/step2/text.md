# Step 2 — Fix it and verify

Two valid fixes. Pick based on intent:

- **Raise the quota** — if 3 replicas is the right answer and the quota was set too low
- **Reduce replicas** — if 2 was the intended replica count and someone bumped it by mistake

In a real incident with no other context, either gets the alert to clear. The choice is a *production* question (covered below). For this scenario, raise the quota — it's the more useful pattern to know.

## Raise the quota

Raising to **3** — exactly enough to satisfy the Deployment, no slack. (Adding headroom like `5` is a judgment call; in production you'd justify the bump via capacity review. For triage, match the actual demand.)

```bash
kubectl patch resourcequota pod-limit -n number-porting --type=merge \
  -p '{"spec":{"hard":{"pods":"3"}}}'
```{{exec}}

Or with `kubectl edit`:

```bash
kubectl edit resourcequota pod-limit -n number-porting
# change spec.hard.pods from "2" to "3"
```

> ⚠️ `kubectl edit` opens both `spec` and `status`. Change **`spec.hard.pods`** — `status.hard.pods` is controller-managed and edits to it get reverted within a second. The same `spec` (yours) / `status` (controller's) split applies to every Kubernetes object.

## Watch the third pod schedule

```bash
kubectl get pods -n number-porting -w
```{{exec}}

You should see the third pod appear, transition through `Pending → ContainerCreating → Running`. Once you see all three Running, `Ctrl-C` to exit the watch.

## Verify

```bash
kubectl get deploy port-processor -n number-porting
```{{exec}}

`READY 3/3`. The deployment is satisfied.

```bash
kubectl get events -n number-porting --sort-by='.lastTimestamp' | tail -5
```{{exec}}

Recent events should show `SuccessfulCreate` instead of `FailedCreate`.

## What this scenario tested

Three instincts:

- Did you reach for `kubectl get events` or `kubectl describe rs` when pod-level checks came up empty? That's the climb-the-owner-chain instinct.
- Did you understand that `kubectl describe pod` only sees events on Pods, not on the controllers that create them?
- Did you stop to ask "should I raise the quota or reduce replicas?" — quotas exist for a reason; the production answer depends on whether the quota was wrong or the desired replica count was wrong.

For the full canonical walkthrough and self-grading, see `ANSWER-KEY.md`.

## Production thinking

`ResourceQuota` is a guardrail. Raising it to bypass a failure trains the wrong instinct — eventually quotas don't constrain anything. In production:

1. Find out *why* the Deployment wants 3 replicas (was it scaled? was the manifest updated? does the workload actually need 3?).
2. If 3 is correct: open a PR raising the quota with justification (capacity review, cost impact).
3. If 3 is wrong: revert the replica change in your GitOps source of truth, not via `kubectl scale`.

Either way, the `kubectl patch` you just ran is a triage step — not a fix. Flux will re-apply the original manifest on its next reconciliation and you'll be back at READY 2/3 unless the gitops source matches your intent.

You're done with breakfix-03. See `finish.md`.
