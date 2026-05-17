# Step 2 — The Polyphone fleet

Polyphone is a real-time communications platform. Its workloads are organized by **architectural plane**:

| Plane         | What lives there                                       | Namespaces                                  |
|---------------|--------------------------------------------------------|---------------------------------------------|
| **media**     | RTP media servers, transcoding, session brokering      | `media`                                     |
| **signaling** | SIP routing, proxying, endpoint registration           | `signaling`                                 |
| **app**       | Telephony application logic, presence, directory       | `app-services`                              |
| **edge**      | North-south session border controllers, PSTN gateways  | `edge`                                      |
| **control**   | Provisioning, routing, CDR, analytics, number porting  | `provisioning`, `call-routing`, `cdr-storage`, `analytics`, `number-porting` |
| **admin**     | Operator-facing portal                                 | `admin-portal`                              |

Every workload carries a `plane=...` label. You'll use that label a lot in later modules (notably M10 — NetworkPolicies).

## See the whole fleet at once

```bash
kubectl get pods -A
```{{exec}}

This is the canonical "what's running anywhere on this cluster" command. Memorize it. It is the first thing you should type whenever you're triaging an unfamiliar situation.

You should see ~25 pods spread across the Polyphone namespaces, plus the `kube-system`, `local-path-storage`, and `kube-public` infrastructure namespaces.

## Filter by plane

```bash
kubectl get pods -A -l plane=media
```{{exec}}

```bash
kubectl get pods -A -l plane=signaling
```{{exec}}

The `plane` label cuts the fleet by architectural responsibility. In later modules you'll use this to apply policy, scale together, or scope debugging.

## Look at the different workload types

Polyphone uses every major workload archetype:

```bash
kubectl get deployments -A
```{{exec}}

```bash
kubectl get statefulsets -A
```{{exec}}

```bash
kubectl get daemonsets -A
```{{exec}}

You'll see Deployments for stateless workloads (`sip-router`, `portal-ui`), StatefulSets where stable network identity matters (`media-engine`, `reg-proxy`, `presence`, `pstn-gateway`), and a DaemonSet for the per-node `sbc-edge` agent.

## Verify

```bash
kubectl get ns -l '!kubernetes.io/metadata.name' 2>/dev/null
kubectl get pods -A --no-headers | wc -l
```{{exec}}

You should see 10 Polyphone namespaces and ~25 total pods.

Move on to step 3.
