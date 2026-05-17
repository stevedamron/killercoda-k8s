# Done

You triaged a cluster-wide alert with no namespace hint, found the broken workload using `kubectl get pods -A` (or `kubectl get events -A --sort-by='.lastTimestamp'`), and recovered it with `kubectl set image`. That instinct — pivot to cluster-wide first, zoom in second — is the single most important habit M00 wants to give you.

**Next:**

- For the *why*, see [LESSON.md](../LESSON.md) — the diagnostic loop section in particular.
- Two more M00 break/fix scenarios are coming: `breakfix-02` (event-only failures), `breakfix-03` (wrong context vs wrong namespace).
- When you're ready to move on, **M01 (Workloads I — Pods, Deployments, ReplicaSets)** is the next module on the linear path.
