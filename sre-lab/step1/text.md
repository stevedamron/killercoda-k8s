# Operational Tasks

Complete these tasks to demonstrate your comfort with day-to-day Kubernetes operations. Work through as many as you can — speed matters here.

## Available tools

- `kubectl` / `k` (aliased)
- `k9s` — terminal UI for Kubernetes
- `helm`
- AI assistants (if available)

---

### Context & Config
1. List all available **kubectl contexts** on this cluster
2. Set your default namespace to `admin-portal` so you don't need `-n` on every command
3. Switch back to the **default** namespace when done

### Resource Inspection
4. Show the **resource requests and limits** for all pods in `call-analytics`
5. Check the **resource usage** (CPU/memory) of all pods across the cluster
6. Which **node** is each `portal-ui` pod running on?
7. Export the full **YAML manifest** of the `route-engine-svc` service in `call-routing`
8. List all **ResourceQuotas** across the entire cluster
9. What **ServiceAccounts** exist in the `provisioning` namespace?

### Scaling & Rollouts
10. Scale the `portal-ui` deployment in `admin-portal` to **5 replicas**
11. Perform a **rolling restart** of the `route-engine` deployment in `call-routing`
12. Check the **rollout status** of that restart
13. Show the **rollout history** for `route-engine` in `call-routing`

### Logs & Debugging
14. Show the logs from the **previous crashed container** in `call-analytics`
15. **Exec into** a `route-engine` pod in `call-routing` and test connectivity to its service from inside

### Service & Networking
16. List all **endpoints** for `portal-ui-svc` in `admin-portal`
17. What **ClusterIP** is assigned to `route-engine-svc` in `call-routing`?
18. **Expose** the `cdr-writer` deployment in `cdr-storage` as a new ClusterIP service on port 80
