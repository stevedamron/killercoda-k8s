# Step 4 — JSON unpacking and queries

Every Kubernetes object is JSON under the hood. Three tools let you pull specific fields out — pick whichever fits the question you're asking.

## Grab one field — `-o jsonpath`

What image is the `portal-ui` Deployment running?

```bash
kubectl get deployment portal-ui -n admin-portal \
  -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```{{exec}}

You get back just the image string. Use `-o jsonpath` when you want one specific field, often piped into a script.

## Make a quick table — `-o custom-columns`

Which node is each Pod scheduled on?

```bash
kubectl get pods -A -o custom-columns=NS:.metadata.namespace,NAME:.metadata.name,NODE:.spec.nodeName | head -15
```{{exec}}

Columns are `HEADER:.path.to.field`, comma-separated. Useful for ad-hoc reports without leaving kubectl.

## Filter and reshape — `jq`

How many Pods does each namespace have?

```bash
kubectl get pods -A -o json | jq -r '.items[] | .metadata.namespace' | sort | uniq -c | sort -rn
```{{exec}}

`jq` reads `-o json` output and lets you filter (`select(...)`), transform (`map`, `group_by`), or compose new strings. Reach for it when jsonpath isn't enough.

## When to use which

| You want… | Reach for |
|---|---|
| One field, scriptable | `-o jsonpath` |
| A quick table | `-o custom-columns` |
| Filter / transform / pipe | `\| jq` |

Move on to step 5.
