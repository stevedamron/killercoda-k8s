# M00 — Break/fix 03: Event-Only Failure

> Pre-req: completed M00 baseline tour, or comfortable with the `get → describe → events → logs` loop.

Polyphone monitoring fires an alert: **`port-processor` Deployment in `number-porting`: desired=3, available=2**. One replica is missing.

You open a terminal and check the obvious. The two pods that exist are `Running`, `1/1 READY`, zero restarts. `kubectl describe` on the pods shows nothing wrong. `kubectl logs` is quiet. Yet the Deployment is still short a replica.

**The answer isn't on any Pod.** This scenario tests the second-most-skipped step in the diagnostic loop: knowing when to climb the owner chain.

The cluster takes 60–120 seconds to come up. Click **Start** when ready.
