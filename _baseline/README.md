# The Polyphone Baseline Cluster

The known-good reference cluster that every lesson starts from. Spins up the full 17-workload Polyphone fleet across 10 namespaces.

## What's in here

| File              | Purpose                                                    |
|-------------------|------------------------------------------------------------|
| `background.sh`   | The canonical baseline. Run on Killercoda boot to provision the full fleet. |

Per-lesson scenarios copy this `background.sh` into their own scenario directory and then append mutations to create a broken-cluster sibling.

## The fleet

10 namespaces, 17 workloads, organized by architectural plane:

```
media plane          signaling plane       app plane             edge plane
├─ media-engine      ├─ sip-router         ├─ sip-app            ├─ sbc-edge
├─ session-broker    ├─ sip-proxy          ├─ presence           ├─ pstn-gateway
└─ transcoder        └─ reg-proxy          └─ directory

control / admin plane
├─ account-provisioner   (provisioning)
├─ portal-ui             (admin-portal)
├─ route-engine          (call-routing)
├─ cdr-writer            (cdr-storage)
├─ metrics-aggregator    (analytics)
└─ port-processor        (number-porting)
```

## What gets installed alongside the fleet

The script also installs:

- **local-path-provisioner** — gives us a `local-path` StorageClass so PVCs work (Killercoda's kubeadm image ships without one)
- **metrics-server** — so `kubectl top` works (with `--kubelet-insecure-tls` for the local cluster)
- **k9s** — installed in `/usr/local/bin` for learners who prefer a TUI
- The worker node gets labeled `disktype=ssd` so workloads with nodeAffinity (`transcoder`, `media-engine`) schedule cleanly

## Resource footprint

The full fleet runs ~25 pods. On Killercoda's `kubernetes-kubeadm-2nodes` image this is comfortably within capacity but takes 60–120 seconds to fully come up. The script uses `kubectl wait --for=condition=Available` at the end to ensure the cluster is ready before the learner sees it.

## Workload images

All workloads use lightweight upstream images (`nginx:1.25`, `busybox:1.36`) to keep the cluster fast. This is acceptable because lessons teach Kubernetes primitives, not the implementation details of real telephony software. Where realistic protocol behavior matters (e.g. M17 host networking), the lesson swaps in a more representative image locally.

## Idempotency

The script is idempotent: rerunning it should not break a running cluster. Namespaces are created with `--dry-run | apply` so reruns succeed cleanly.

## When this changes

Changes to the baseline ripple through every module. Don't add workloads here without updating:

1. `CURRICULUM.md` — the fleet table
2. `_internal/vernacular.md` — the workload archetypes table
3. Every module's scenario `background.sh` copies (or the build pipeline that generates them)
