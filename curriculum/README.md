# Polyphone — Kubernetes Curriculum for SREs

A hands-on, scenario-based curriculum that teaches Kubernetes by operating a fictional real-time communications platform called **Polyphone**. Every lesson runs on [Killercoda](https://killercoda.com) and pairs a known-good cluster with broken-cluster siblings that exercise one diagnostic skill at a time.

## Who this is for

Site reliability engineers, platform engineers, and infrastructure engineers who need to:

- Build durable Kubernetes intuition, not just memorize `kubectl` commands
- See how K8s primitives compose into a realistic production platform
- Practice diagnosis on representative failure modes before encountering them in production

No prior Kubernetes experience is assumed for `M00`. Each module builds on earlier ones; vocabulary and patterns compound.

## How a lesson is structured

Every lesson is a **trio**:

1. **Killercoda scenario** — `baseline/` (known-good cluster tour) + `breakfix-NN/` (broken siblings). Run in-browser; sidebar walks through hands-on steps.
2. **`LESSON.md`** — a standalone companion doc. The *why*, key vocabulary, mental model, and links to authoritative documentation. Read it alone or alongside the lab.
3. **`ANSWER-KEY.md`** — the canonical diagnostic walkthrough for each break/fix scenario: symptom → root cause → diagnostic commands → fix → what the scenario tests → expected time. Try the scenario first, then come back and grade your own approach.

Style across all three: simple, readable, succinct, thorough. No filler.

## Module map

See [CURRICULUM.md](CURRICULUM.md) for the full curriculum plan, module progression, and learning objectives.

## Repository layout

```
curriculum/
  README.md                          (this file)
  CURRICULUM.md                      (master plan: modules, persona, philosophy)
  _internal/                         (author-only — not in the public repo)
    lesson-template.md               (canonical lesson format spec)
    style-guide.md                   (voice, length, conventions)
  _baseline/                         (the shared 17-workload Polyphone fleet)
    background.sh                    (canonical: spins up the full fleet)
    README.md                        (what's in the fleet and why)
  m00-foundations/                   (one directory per module)
    LESSON.md
    ANSWER-KEY.md
    baseline/                        (killercoda scenario — known-good tour)
    breakfix-01-<name>/              (killercoda scenario — broken sibling)
  m01-workloads-i/
  m02-configuration/
  ...
```

## The Polyphone persona

All labs are framed as "you are an SRE at **Polyphone**, a fictional real-time communications SaaS." Polyphone operates a global multi-cluster fleet running the full real-time stack: media servers, SIP signaling, registration, telephony application logic, presence, directory, session border controllers, PSTN gateways, plus the usual admin/analytics/provisioning plane.

Polyphone is fictional. The platform shape — workload archetypes, namespace organization, GitOps patterns — is inspired by industry-standard practice across the real-time communications space. Nothing here describes any real company's internal systems.

## Running a lesson locally

Each lesson's `baseline/` and `breakfix-NN/` directories are valid Killercoda scenarios. To run one:

1. Push the scenario directory (or this repo) to a public Git repo
2. Visit `https://killercoda.com/<your-user>/scenario/<scenario-path>`
3. Wait for the background script to finish provisioning the cluster
4. Follow the sidebar instructions

Local-only authoring: read `LESSON.md` for the concept, then read `ANSWER-KEY.md` for the diagnostic walkthroughs.
