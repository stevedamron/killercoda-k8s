# Operational Cluster — Reference Environment

This scenario mirrors the SRE Interview Lab cluster exactly — same namespaces, same services, same telco workload structure — but **everything is healthy**. No broken references, no OOMKills, no scheduling failures, no service selector mismatches.

Use this environment to:

- Practice `kubectl` and `k9s` commands against a clean, known-good cluster.
- Verify what "normal" looks like before tackling the break/fix lab.
- Validate that operational workflows (scale, restart, logs, exec) behave as expected.

The cluster is being prepared in the background — 8 namespaces, ~11 pods. Click **Start** when ready.
