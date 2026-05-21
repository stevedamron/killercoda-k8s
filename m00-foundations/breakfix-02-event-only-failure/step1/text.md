# Step 1 — Find the missing replica

The Deployment wants 3 replicas; only 2 are available. Start with the obvious checks.

## Check the Deployment

```bash
kubectl get deploy port-processor -n number-porting
```{{exec}}

`READY 2/3`. Confirmed.

## Check the Pods

```bash
kubectl get pods -n number-porting
```{{exec}}

Two pods, both `Running`, `1/1 READY`. The pods that exist are healthy.

```bash
kubectl describe pod -n number-porting -l app=port-processor
```{{exec}}

Events on the existing pods show clean scheduling, image pull, container start. Nothing wrong.

You're at the limit of what pod-level inspection can tell you. The missing pod was never created — there's nothing to describe.

## Climb the owner chain

A Deployment doesn't create Pods directly. It creates a ReplicaSet; the ReplicaSet creates Pods. When pod creation fails, the failure event lives on the ReplicaSet.

```bash
kubectl get rs -n number-porting
```{{exec}}

You'll see one ReplicaSet for port-processor with `DESIRED 3`, `CURRENT 2`. Describe it:

```bash
kubectl describe rs -n number-porting -l app=port-processor
```{{exec}}

Look at the `Events:` section at the bottom. You should see:

```text
  Warning  FailedCreate  ...  Error creating: pods "port-processor-..." is forbidden:
                              exceeded quota: pod-limit, requested: pods=1, used: pods=2, limited: pods=2
```

That's the answer. A `ResourceQuota` in the namespace caps total pods at 2, and the Deployment wants 3.

## The shortcut: `kubectl get events`

When pod-level checks come up empty, this is your shortcut:

```bash
kubectl get events -n number-porting --sort-by='.lastTimestamp'
```{{exec}}

The same `FailedCreate` event surfaces in seconds. No need to climb the owner chain manually if you remember `events` is part of the diagnostic loop.

## Verify the quota

```bash
kubectl get resourcequota -n number-porting
```{{exec}}

```text
NAME        REQUEST     LIMIT   AGE
pod-limit   pods: 2/2           ...
```

The `pods: 2/2` in the REQUEST column reads as `used/hard` — the namespace is already at its pod ceiling. For the full breakdown:

```bash
kubectl describe resourcequota pod-limit -n number-porting
```{{exec}}

```text
Resource  Used  Hard
pods      2     2
```

The quota is the constraint. Move to step 2.
