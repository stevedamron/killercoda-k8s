## Explore a healthy production cluster

This environment is structurally identical to the SRE Interview Lab, but every workload is operational. Use it to get comfortable navigating, reading state, and running everyday operational commands without any break/fix pressure.

## Available tools

- `kubectl` / `k` (aliased)
- `k9s` — terminal UI for Kubernetes
- `helm`

---

### Orient yourself
1. List all available **kubectl contexts** on this cluster
2. Set your default namespace to `admin-portal` so you don't need `-n` on every command
3. Switch back to the **default** namespace when done

### Understand what's running
4. Show the **resource requests and limits** for all pods in `call-analytics`
5. Check the **resource usage** (CPU/memory) of all pods across the cluster
6. Which **node** is each `portal-ui` pod running on?
7. Export the full **YAML manifest** of the `route-engine-svc` service in `call-routing`
8. List all **ResourceQuotas** across the entire cluster
9. What **ServiceAccounts** exist in the `provisioning` namespace?

### Practice common operations
10. Scale the `portal-ui` deployment in `admin-portal` to **5 replicas**
11. Perform a **rolling restart** of the `route-engine` deployment in `call-routing`
12. Check the **rollout status** of that restart
13. Show the **rollout history** for `route-engine` in `call-routing`

### Check logs and connectivity
14. Show the **recent logs** from the `route-engine` pods in `call-routing`
15. **Exec into** a `route-engine` pod in `call-routing` and test connectivity to its service from inside

### Review service networking
16. List all **endpoints** for `route-engine-svc` in `call-routing`
17. What **ClusterIP** is assigned to `route-engine-svc` in `call-routing`?
