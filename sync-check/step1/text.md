# Verify the cluster is healthy

A few quick commands to confirm everything came up cleanly.

## List the telco namespaces

```
kubectl get ns voice-gateway sms-router billing-events
```

All three should show **Active**.

## Confirm every pod is running

```
kubectl get pods -A | grep -E "voice-gateway|sms-router|billing-events"
```

You should see:

- `voice-gateway/sip-proxy-*` — 2 pods, all `Running`, `1/1` ready
- `sms-router/message-dispatcher-*` — 1 pod, `Running`, `1/1` ready
- `billing-events/event-collector-*` — 1 pod, `Running`, `1/1` ready

## Check the sip-proxy service has endpoints

```
kubectl get endpoints sip-proxy-svc -n voice-gateway
```

The `ENDPOINTS` column should list 2 pod IPs (one per replica).

---

If all three checks look good, **the sync from your GitHub fork to killercoda is working**. Click **Next** to finish.
