# Done

You triaged a cluster-wide alert with no namespace hint, found the broken workload using `kubectl get pods -A` (or `kubectl get events -A --sort-by='.lastTimestamp'`), and recovered it with `kubectl set image`. That instinct — pivot to cluster-wide first, zoom in second — is the single most important habit M00 wants to give you.

**Next:**

- For the canonical walkthrough and self-grading questions, see [`ANSWER-KEY.md`](../ANSWER-KEY.md).
- For the *why*, see [LESSON.md](../LESSON.md) — the diagnostic loop section in particular.
- One more M00 break/fix awaits: **`breakfix-03-event-only-failure`** — when Pod-level checks come up empty and the answer lives one level up on the controller.
