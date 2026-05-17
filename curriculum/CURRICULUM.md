# Polyphone Kubernetes Curriculum — Master Plan

The long-term curriculum, organized as four tiers. Tier 1 and Tier 2 are strictly linear and required for everyone. Tier 3 splits into three branchable tracks that can be taken in any order. Tier 4 is the capstone.

## Persona

You are an SRE at **Polyphone**, a fictional real-time communications SaaS. Polyphone operates a global fleet of Kubernetes clusters across regions (`us-east-1`, `us-west-2`, `eu-central-1`, `ap-southeast-1`) and tiers (`dev`, `lab`, `stage`, `prod`). The platform delivers voice, video, and messaging via a stack of media servers, SIP signaling components, telephony application logic, edge gateways, and the usual control/data/admin planes.

## The Polyphone fleet (17 workloads, 10 namespaces)

| Namespace        | Workload              | Role                                            |
|------------------|-----------------------|-------------------------------------------------|
| `media`          | `media-engine`        | RTP media processing (StatefulSet)              |
| `media`          | `session-broker`      | Allocates media resources                       |
| `media`          | `transcoder`          | Codec conversion (CPU-affinity)                 |
| `signaling`      | `sip-router`          | SIP request routing                             |
| `signaling`      | `sip-proxy`           | Front-edge SIP proxy                            |
| `signaling`      | `reg-proxy`           | Endpoint registration (StatefulSet)             |
| `app-services`   | `sip-app`             | SIP application server (call logic)             |
| `app-services`   | `presence`            | Presence/availability (StatefulSet)             |
| `app-services`   | `directory`           | Address book / contacts                         |
| `edge`           | `sbc-edge`            | Session Border Controller (DaemonSet)           |
| `edge`           | `pstn-gateway`        | PSTN trunk gateway (StatefulSet)                |
| `provisioning`   | `account-provisioner` | Tenant provisioning                             |
| `admin-portal`   | `portal-ui`           | Admin web UI                                    |
| `call-routing`   | `route-engine`        | Call routing decisions                          |
| `cdr-storage`    | `cdr-writer`          | Call Detail Records (PVC)                       |
| `analytics`      | `metrics-aggregator`  | Telemetry aggregation                           |
| `number-porting` | `port-processor`      | LNP workflows (ResourceQuota)                   |

The full fleet boots in every lesson's `baseline/` scenario. Each module's break/fix scenarios mutate one or two of these workloads to create a learnable failure.

## Module map

### Tier 1 — Foundations (linear)

| ID  | Title                                     | Core concepts                                                   |
|-----|-------------------------------------------|-----------------------------------------------------------------|
| M00 | Mental Model & kubectl Fluency            | Cluster anatomy, contexts, namespaces, the resource model       |
| M01 | Workloads I — Pods, Deployments, ReplicaSets | Lifecycle, probes, controllers, declarative reconciliation     |
| M02 | Configuration                             | ConfigMaps, Secrets, env injection, projected volumes           |
| M03 | Networking I — Services & DNS             | Service types, Endpoints, kube-proxy, CoreDNS                   |
| M04 | Storage                                   | PV/PVC, StorageClass, CSI, RWO vs RWX, dynamic provisioning     |
| M05 | Scheduling                                | Requests/limits, QoS, affinity, taints, topology spread         |
| M06 | Workloads II — StatefulSets, DaemonSets, Jobs | Stable identity, ordered rollout, node-local agents, batch    |

### Tier 2 — Operational Depth (linear)

| ID  | Title                                     | Core concepts                                                   |
|-----|-------------------------------------------|-----------------------------------------------------------------|
| M07 | Resilience                                | PDBs, HPA, rolling updates, rollbacks, graceful shutdown        |
| M08 | Security                                  | RBAC, SAs, SecurityContext, PodSecurity, secrets-at-rest        |
| M09 | Observability                             | Events, logs, metrics-server, `top`, sidecar logging patterns   |
| M10 | Networking II — Policy & Ingress          | NetworkPolicies, Ingress controllers, service mesh primer       |

### Tier 3 — Platform Engineering (branchable)

**Track A — GitOps**
| ID  | Title                  | Core concepts                                            |
|-----|------------------------|----------------------------------------------------------|
| M11 | Kustomize Bases & Overlays | Composition, patches, components, generators        |
| M12 | Helm Fundamentals      | Charts, values, templating, when to choose Helm vs Kustomize |
| M13 | Flux                   | GitRepository, Kustomization, HelmRelease, dependencies, drift |
| M14 | Multi-cluster Fleet    | Cluster vars, promotion (lab → stage → prod), per-region overlays |

**Track B — Policy & Compliance**
| ID  | Title                  | Core concepts                                            |
|-----|------------------------|----------------------------------------------------------|
| M15 | Kyverno / OPA Gatekeeper | Policy-as-code, validation, mutation, generation     |
| M16 | Admission Control      | Validating vs mutating webhooks, admission ordering     |

**Track C — Real-Time / Latency-Sensitive Workloads**
| ID  | Title                  | Core concepts                                            |
|-----|------------------------|----------------------------------------------------------|
| M17 | Host Networking & Multi-NIC | hostNetwork, hostPort, Multus, CNI plumbing for RTP |
| M18 | CPU & Memory Tuning    | CPU Manager, NUMA, topology manager, hugepages, RT kernel basics |
| M19 | Stateful Coordination  | Leader election, headless Services, StatefulSet identity, persistent caches |

### Tier 4 — Capstone

| ID  | Title                                     | Core concepts                                                   |
|-----|-------------------------------------------|-----------------------------------------------------------------|
| M20 | Failure & Recovery                        | Control plane, etcd basics, CSI failure, GitOps rollback        |
| M21 | Operate the Platform                      | Multi-broken-cluster triage; integrates Tier 1–3                |

## Lesson design philosophy

**Concept first, then practice, then self-grade.** The companion `LESSON.md` introduces the concept and mental model. The Killercoda `baseline/` scenario lets you see it working. The `breakfix-NN/` scenarios force you to debug it. The `ANSWER-KEY.md` shows the canonical diagnostic path so you can grade your own approach after — it's a learner-facing reference, not a hidden instructor key.

**One concept per break/fix scenario.** A scenario tests one diagnostic skill. Combining multiple bugs into one scenario teaches frustration, not Kubernetes.

**The platform is always the same.** Every lesson uses the same Polyphone fleet. Learners build familiarity with the same namespaces, the same workloads, the same vocabulary. By M10 they know the platform as well as they know their own production system.

**Earned vocabulary.** Each module assumes everything taught in earlier modules. `LESSON.md` cross-references back ("see M03 for Service basics"). The curriculum is cumulative, not encyclopedic.

**Production thinking.** Every `ANSWER-KEY.md` ends with a "what would you do in production" prompt. Diagnosis is necessary but not sufficient; reasoning about blast radius, runbooks, and post-incident action is what separates strong SREs.

**Authoritative references.** Every concept links out to k8s.io, kustomize.io, fluxcd.io, CNCF docs, or canonical IETF/3GPP terminology where appropriate. The curriculum is a curated path through the official docs, not a replacement for them.

## Voice and length

| Artifact          | Length target           | Voice                                            |
|-------------------|-------------------------|--------------------------------------------------|
| Sidebar `text.md` | ~300–600 words per step | Imperative, conversational, code-heavy           |
| `LESSON.md`       | ~1500–3000 words        | Explanatory, mental-model focused, well-linked   |
| `ANSWER-KEY.md`   | ~150–400 words per scenario | Terse, opinionated, what-to-watch-for          |

See `_internal/style-guide.md` for the full conventions.

## Status

| Module                 | LESSON.md | ANSWER-KEY.md | baseline/ | breakfix-NN/ |
|------------------------|-----------|---------------|-----------|--------------|
| M00 Foundations        | ✅        | ✅            | ✅        | 1 of 3       |
| M01 Workloads I        | —         | —             | —         | —            |
| M02 Configuration      | —         | —             | —         | —            |
| ... (remaining)        | —         | —             | —         | —            |

This table is the authoring backlog; update as each module ships.
