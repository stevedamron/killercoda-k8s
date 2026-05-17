# M00 — Mental Model & kubectl Fluency — Answer Key

> Self-grading reference. Try each scenario first, then come back here to check your diagnostic path against the canonical one. Instructors running the lab live can use the same sections as a teaching script.
> Environment: Killercoda `kubernetes-kubeadm-2nodes` with the Polyphone baseline.

## Lesson summary

M00 teaches the mental model and the four-command diagnostic loop. The `baseline/` scenario walks you through cluster anatomy, the fleet, and the loop against a healthy workload. The `breakfix-01-context-blindness/` scenario tests the most fundamental instinct: when you don't know where a problem lives, can you scan the cluster cluster-wide to find it?

## Baseline tour reference

The baseline has no broken state. Each step produces predictable output. If a step doesn't behave as expected, here's what to check.

- **Step 1 (anatomy):** `kubectl get nodes -o wide` shows 2 nodes (control-plane + worker). `kubectl get pods -n kube-system` shows the core control-plane pods (`etcd`, `kube-apiserver`, `kube-controller-manager`, `kube-scheduler`, `kube-proxy`, `coredns`). If those names aren't familiar yet, read [LESSON.md](LESSON.md) § Vocabulary — they recur in every later module.
- **Step 2 (fleet tour):** `kubectl get pods -A` reveals 10 Polyphone namespaces alongside `kube-system`, `local-path-storage`, and `kube-public`. Notice the `plane=media|signaling|...` labels — they segment the fleet by architectural responsibility and you'll use them in M10 for NetworkPolicies.
- **Step 3 (diagnostic loop):** Walks `get → describe → events → logs` against the healthy `portal-ui` Deployment. The point is the *pattern*, not the diagnosis (nothing is wrong). After this step you should be able to repeat the loop on any Pod in any namespace.

---

## Break/fix 01 — Context Blindness

**Symptom:** An alert fires: "Polyphone fleet — one or more workloads degraded." No namespace, no workload name, no hint about what's wrong.

**Root cause:** The `metrics-aggregator` Deployment in the `analytics` namespace has its container image set to `nginx:doesnotexist-1.25-foobar`. Pods are stuck in `ImagePullBackOff` — the kubelet's status for "I tried to pull this image, the registry said no, and I'm now backing off retries"<sup><a href="https://kubernetes.io/docs/concepts/containers/images/#imagepullbackoff">[1]</a></sup>.

**Diagnostic commands (the canonical path):**

```bash
# 1. Scan cluster-wide — the M00 instinct
kubectl get pods -A
# One workload stands out: STATUS = ImagePullBackOff or ErrImagePull, namespace = analytics
```

```bash
# 2. OR sort events cluster-wide — often faster
kubectl get events -A --sort-by='.lastTimestamp' | tail -30
# "Failed to pull image" events bubble to the bottom
```

```bash
# 3. Zoom in
kubectl describe pod -n analytics -l app=metrics-aggregator
# Events section: Failed to pull image "nginx:doesnotexist-1.25-foobar"
```

**Fix:**

```bash
# Option A: kubectl set image (one-liner; good for the immediate recovery)
kubectl set image deployment/metrics-aggregator app=nginx:1.25 -n analytics

# Option B: kubectl edit (good when you want to inspect the whole manifest)
kubectl edit deployment metrics-aggregator -n analytics
# Change spec.template.spec.containers[0].image to nginx:1.25
```

**Verify:**

```bash
# -w watches until you Ctrl-C; the new Pod transitions through Pending -> Running
kubectl get pods -n analytics -w
```

When done, confirm the fleet is back to green:

```bash
kubectl get pods -A --field-selector=status.phase!=Running --no-headers | wc -l
# Expect 0 (or a brief transient as old ReplicaSets clean up)
```

**What this scenario tests:** The lesson is not fixing an image typo — that's trivial. The lesson is **finding the broken thing without being told where**. Self-grading questions:

- Did your first command include `-A`? That's the single biggest separator between strong and weak diagnostic flow.
- Did you reach for `kubectl get events -A --sort-by='.lastTimestamp'`? That command surfaces the failure as plain text in seconds. If you found the problem without it, fine — but build the habit, because some failures are event-only (the Pod shows no symptom; the event on the owning ReplicaSet does).
- Did you open one namespace at a time, hoping to guess right? That's the anti-pattern. It scales linearly with cluster size and feels productive while wasting minutes.

<details>
<summary>📖 Going deeper: <code>--field-selector</code> is the senior's <code>grep</code><sup><a href="https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/">[2]</a></sup></summary>

`kubectl get pods -A` returns everything. Real clusters have thousands of Pods; that output is unreadable. Three flags make it tractable:

- `--field-selector=status.phase!=Running` — only the unhappy ones
- `--field-selector=spec.nodeName=<node>` — only Pods on a specific node (useful when triaging a node-level issue)
- `-o jsonpath='...'` — extract only the field you care about

Combine them:

```bash
# All non-Running pods cluster-wide, with their namespace and phase
kubectl get pods -A --field-selector=status.phase!=Running \
  -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,PHASE:.status.phase
```

The list of selectable fields per resource is limited (Kubernetes doesn't index every field for selection)<sup><a href="https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/">[2]</a></sup>. The most useful set: `metadata.name`, `metadata.namespace`, `spec.nodeName`, `status.phase`. Everything else needs `jq` or jsonpath on the output.

</details>

**Expected time:** 1–2 minutes once the cluster-wide instinct is internalized; 3–6 minutes the first time through.

**Production thinking:** `kubectl set image` is a bandaid. It works, but the change isn't reflected in your GitOps source of truth. On the next Flux reconciliation, the cluster could drift back to the broken state — or worse, your fix gets reverted when an unrelated PR merges. The production fix:

1. Triage with `kubectl set image` to stop the bleeding.
2. Open a PR to `platform-gitops` correcting the manifest.
3. Let Flux re-apply the corrected manifest, eliminating the out-of-band fix.
4. Post-mortem: how did the bad image tag merge in the first place? Should CI block deployments referencing non-existent images?

`kubectl` changes are temporary unless the source of truth agrees. You'll meet Flux and the GitOps loop in M11–M14. For now, take away the principle.

## References

1. Kubernetes — Image Pull Backoff: https://kubernetes.io/docs/concepts/containers/images/#imagepullbackoff
2. Kubernetes — Field Selectors: https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/
