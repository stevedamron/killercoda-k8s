# Step 3 — Common kubectl idioms

Before the diagnostic loop, get fluent in the commands you'll actually type day-to-day. This step is a fluency drill — try each command and read what it does. Nothing is broken; the cluster is the same healthy fleet you toured in step 2.

## The eight verbs you'll use 90% of the time

| Verb | What it does | When you reach for it |
|---|---|---|
| `get` | List objects | "What's there?" — always step 1. |
| `describe` | Pretty-print one object + its recent events | "What happened to this specific thing?" |
| `logs` | Stream a container's stdout/stderr | "What does the app think?" |
| `exec` | Run a command inside a running container | "I need to inspect/test from inside." |
| `apply` | Create or update from a manifest | The GitOps verb. Use this 95% of the time when changing state. |
| `edit` | Open the live object in `$EDITOR`, save to apply | Quick interactive tweak. **Triage tool**, not GitOps. |
| `delete` | Remove an object (cascades to dependents by default) | Cleanup. |
| `port-forward` | Tunnel a local port to a Pod or Service | Test a service without exposing it. |

Try the read-only verbs on the healthy fleet:

```bash
kubectl get pods -n admin-portal
```{{exec}}

```bash
kubectl describe deployment portal-ui -n admin-portal | head -40
```{{exec}}

```bash
kubectl logs -n admin-portal -l app=portal-ui --tail=5
```{{exec}}

```bash
kubectl exec -n admin-portal deploy/portal-ui -- hostname
```{{exec}}

## Flags you'll combine endlessly

| Flag | What it does |
|---|---|
| `-n <ns>` | Scope to a namespace |
| `-A` (alias `--all-namespaces`) | All namespaces — your fleet-wide instinct |
| `-l key=value` | Filter by label selector (`-l plane=media`) |
| `-o wide` | Wide output — adds Node, IP, etc. |
| `-o yaml` / `-o json` | Full object as YAML / JSON |
| `--watch` (or `-w`) | Stream changes live |
| `-f` (with logs) | Follow / tail logs in real time |
| `-c <container>` | Pick a specific container in a multi-container Pod |
| `--previous` (with logs) | Last terminated container — for after-crash forensics |

Real combinations you'll actually type:

```bash
# What's running on the media plane, with node + IP + age
kubectl get pods -A -o wide -l plane=media
```{{exec}}

```bash
# Full object as YAML — what kubectl describe couldn't show you
kubectl get deployment portal-ui -n admin-portal -o yaml | head -30
```{{exec}}

```bash
# Watch pods in admin-portal for 5 seconds (no changes happening; just see the format)
timeout 5 kubectl get pods -n admin-portal --watch || true
```{{exec}}

> One distinction worth knowing: `kubectl edit` is **triage** (opens the live object, your save applies it, you've now diverged from GitOps); `kubectl apply -f file.yaml` is **declarative** (same operation Flux/Argo run, a three-way merge against your manifest). See LESSON.md for the full contrast and when each is right.

## Asking the cluster what it knows

Two self-help commands that pay for themselves the first day on an unfamiliar cluster.

**`kubectl api-resources`** — every Kind the cluster knows about, with short names and whether it's namespaced. Custom resources installed by CRDs or operators show up here too.

```bash
kubectl api-resources | head -15
```{{exec}}

Filter by API group when you only care about one ecosystem:

```bash
kubectl api-resources --api-group=apps
```{{exec}}

**`kubectl explain`** — built-in schema docs for any resource or field. Faster than guessing at YAML field names.

```bash
kubectl explain pod.spec.containers.livenessProbe
```{{exec}}

`--recursive` dumps every nested field — useful when hunting for where a setting lives:

```bash
kubectl explain deployment.spec --recursive | head -30
```{{exec}}

## Working with running workloads

A handful of idioms you'll reach for constantly when a workload is already up and you need to inspect, talk to, or get metrics out of it. Each is bite-sized — try them on the healthy fleet so the syntax sticks.

**Follow logs live with `-f`; `-c` picks one container in a multi-container Pod:**

```bash
kubectl logs -n admin-portal -l app=portal-ui -f --tail=10 &
sleep 3 && kill %1
```{{exec}}

**Run a one-shot command inside a Pod (faster than ssh, no shell required):**

```bash
kubectl exec -n admin-portal deploy/portal-ui -- ls /etc/nginx
```{{exec}}

For an interactive shell, use `-it`. Not runnable via `{{exec}}` (no terminal), but useful in your own terminal:

```bash
kubectl exec -it -n admin-portal deploy/portal-ui -- sh
# Ctrl-D to exit
```

**Port-forward a Service to localhost — test it without exposing publicly:**

```bash
kubectl port-forward -n admin-portal svc/portal-ui 8080:80 &
sleep 2 && curl -s http://localhost:8080 | head -5 && kill %1
```{{exec}}

**Resource usage** — `kubectl top` queries metrics-server (installed by the baseline):

```bash
kubectl top nodes
```{{exec}}

```bash
kubectl top pods -A --sort-by=cpu | head -10
```{{exec}}

**Services and the Pods behind them** — a Service is a stable virtual IP + DNS name; `Endpoints` is the live list of backing Pod IPs:

```bash
kubectl get svc -A | head -10
```{{exec}}

```bash
kubectl get endpoints -n admin-portal portal-ui
```{{exec}}

The Endpoints object updates automatically as Pods come and go. When a Service "stops working," `kubectl get endpoints` is the first diagnostic — if Endpoints is empty, no Pods match the Service's selector.

Move on to step 4.
