# Kubernetes Scenarios for SREs

Hands-on, scenario-based Kubernetes training that runs in the browser via [Killercoda](https://killercoda.com). Two tracks live here:

- **Long-form curriculum** ([`curriculum/`](curriculum/)) — a structured, multi-module path from K8s foundations through GitOps, policy, real-time workloads, and a capstone. Each module pairs a known-good cluster with broken-cluster siblings, a companion lesson doc, and a self-grading answer key. Built around a fictional real-time communications platform called **Polyphone** so every lesson reinforces the same vocabulary.
- **Standalone scenarios** ([`operational-cluster/`](operational-cluster/), [`sre-lab/`](sre-lab/)) — independent labs. `operational-cluster` is a healthy reference cluster for `kubectl` practice; `sre-lab` is a timed 8-scenario interview-style break/fix assessment.

## Quick start

Each scenario directory is a standalone Killercoda scenario. To run one in the browser:

1. Fork this repo (or push it to your own public Git host).
2. Visit `https://killercoda.com/<your-user>/scenario/<scenario-path>` — for example: `https://killercoda.com/<your-user>/scenario/curriculum/m00-foundations/baseline`
3. Wait for the background script to provision the cluster (60–120 seconds for the full Polyphone fleet).
4. Follow the sidebar instructions.

## Repository layout

```
.
├── README.md
├── answer-key.md                    interviewer reference for sre-lab (also under solutions/)
├── solutions/                       interviewer/learner reference materials
├── operational-cluster/             standalone: healthy reference cluster
├── sre-lab/                         standalone: timed interview break/fix assessment
└── curriculum/                      long-form K8s curriculum
    ├── README.md                    curriculum overview
    ├── CURRICULUM.md                master plan: persona, fleet, module map
    ├── _baseline/                   canonical 17-workload Polyphone fleet
    └── mNN-<topic>/                 one directory per module
        ├── LESSON.md                companion doc
        ├── ANSWER-KEY.md            self-grading reference
        ├── baseline/                killercoda scenario: known-good tour
        └── breakfix-NN-<name>/      killercoda scenario: one broken thing
```

## Where to start

- **New to Kubernetes?** Begin with [`curriculum/m00-foundations/`](curriculum/m00-foundations/). Read `LESSON.md`, then run `baseline/` on Killercoda, then attempt `breakfix-01-context-blindness/` before checking yourself against `ANSWER-KEY.md`.
- **Comfortable with Kubernetes, want practice?** [`operational-cluster/`](operational-cluster/) gives you a fully populated healthy cluster to explore at your own pace.
- **Preparing for an SRE interview?** [`sre-lab/`](sre-lab/) is the timed 8-scenario assessment used by the original interview pack. `answer-key.md` (root) and `solutions/answer-key.md` document the expected diagnostic paths.

## Disclaimer

Polyphone is a fictional company invented for this curriculum. The platform shape — workload archetypes, namespace organization, GitOps patterns — is inspired by industry-standard practice across the real-time communications and platform-engineering space. Nothing here describes any specific real company's internal systems.

## Contributing

Each module follows a canonical lesson trio: Killercoda scenario(s), `LESSON.md`, `ANSWER-KEY.md`. The format is intentionally consistent so learners always know where to find what. New modules should match the existing M00 layout. Issues and PRs welcome.
