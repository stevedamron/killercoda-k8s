# Operational Tasks

Once you've worked through the break/fix scenarios (or when the interviewer moves you on), complete as many of these operational tasks as you can. These test day-to-day K8s comfort.

### Scaling & Rollouts
1. Scale the `portal-ui` deployment in `admin-portal` to **5 replicas**
2. Perform a **rolling restart** of the `route-engine` deployment in `call-routing`
3. Check the **rollout status** of that restart

### Logs & Inspection
4. Show the logs from the **previous crashed container** in `call-analytics`
5. Which **node** is each `portal-ui` pod running on?
6. Export the full **YAML manifest** of the `route-engine-svc` service

### Service & Networking
7. List all **endpoints** for `portal-ui-svc` in `admin-portal`
8. **Exec into** a `route-engine` pod and `curl` the service ClusterIP from inside the pod
9. What **ClusterIP** is assigned to `route-engine-svc`?
10. **Expose** the `cdr-writer` deployment in `cdr-storage` as a new ClusterIP service on port 80
