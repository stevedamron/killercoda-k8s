# M00 — Break/fix 02: Namespace Blindness

> Pre-req: complete the M00 baseline tour, or be comfortable enough with `kubectl` to know what `get`, `describe`, `events`, and `logs` do.

You are on call. A monitoring alert just fired: **"Polyphone fleet — one or more workloads degraded."** It doesn't tell you which namespace, which workload, or what's wrong. Just that something, somewhere, is unhealthy.

You have terminal access to the cluster. **Find it. Fix it.**

This scenario has one explicit bug. The fix itself is trivial. The lesson is the *instinct* to scan cluster-wide before zooming in on any one namespace. A weak diagnostic flow opens namespaces one at a time and may waste 10 minutes; a strong flow finds it in under 60 seconds.

The cluster takes 60–120 seconds to come up plus an extra ~15 seconds for the breakage to manifest. Click **Start** when ready.
