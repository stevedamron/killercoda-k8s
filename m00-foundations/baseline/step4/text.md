# Step 4 — JSON unpacking and queries

Once your kubectl idioms are second nature, the next leap is reading the raw API state. `kubectl get -o yaml` and `kubectl describe` *summarize* — to pull **exactly one field** (for scripting, for piping, for verifying), you need jsonpath or jq.

## Why this matters

Every object in Kubernetes is JSON under the hood. `kubectl get -o yaml` is just JSON pretty-printed as YAML. The skills below let you grab any field, on any object, without `grep`-ing through human-formatted output. That's the difference between "I think Pod X is on node Y" and "here's the exact field, in a script, every time."

## `-o jsonpath` — kubectl's built-in field extractor

`kubectl` ships with a jsonpath implementation. Syntax is close to JavaScript-like dot-access.

```bash
# Pull the image of the first container in a Deployment
kubectl get deployment portal-ui -n admin-portal \
  -o jsonpath='{.spec.template.spec.containers[0].image}'
echo
```{{exec}}

```bash
# All node names, one per line
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
```{{exec}}

```bash
# All Pod names in admin-portal with their phase, tab-separated
kubectl get pods -n admin-portal \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```{{exec}}

The `{range .items[*]}…{end}` template is the most useful pattern — iterate over a list, format each element. Get comfortable with it.

## `-o custom-columns` — when you want a table

If you want columns instead of a stream:

```bash
kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,NODE:.spec.nodeName | head -20
```{{exec}}

Each column is `HEADER:.path.to.field`, comma-separated. Useful for ad-hoc reports without leaving kubectl.

## `jq` — when jsonpath isn't enough

`jq` is the de facto JSON query tool. Pipe `-o json` to it:

```bash
# Get one field
kubectl get deployment portal-ui -n admin-portal -o json | jq '.spec.template.spec.containers[0].image'
```{{exec}}

```bash
# Filter Pods by something not in --field-selector
kubectl get pods -A -o json | \
  jq -r '.items[] | select(.spec.nodeName == "node01") | .metadata.namespace + "/" + .metadata.name' | \
  head -10
```{{exec}}

```bash
# Count Pods per namespace, sorted by count
kubectl get pods -A -o json | \
  jq -r '.items[] | .metadata.namespace' | sort | uniq -c | sort -rn
```{{exec}}

Where jq beats jsonpath: complex filters (`select(...)`), transformations (`map`, `to_entries`), and joining/composing outputs (`+`, string interpolation).

Where jsonpath beats jq: no extra binary needed, simpler one-liners, fewer quote-escaping headaches.

## When to use which

| You want to… | Reach for |
|---|---|
| Grab one specific field | `-o jsonpath='{.path.to.field}'` |
| Build a quick table from list items | `-o custom-columns=COL1:.a,COL2:.b` |
| Filter items by a condition | `\| jq '.items[] \| select(...)'` |
| Transform / reshape output | `\| jq` (map, group_by, to_entries) |
| Pipe to another shell tool | Either — pick whichever is shorter |

> Resist the urge to write 200-character one-liners. If a query has more than one `select` or one transformation, save it as a small bash function or script. Long inline queries are write-only — neither you nor your teammate will read them six months later.

Move on to step 5.
