#!/bin/bash

# Wait for cluster
while ! kubectl get nodes 2>/dev/null | grep -q " Ready"; do
  sleep 2
done
sleep 5

# ============================================================
# CLUSTER PREREQUISITES
# Install local-path-provisioner so PVC scenarios work correctly.
# This gives us a "local-path" StorageClass (RWO only).
# ============================================================
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml 2>/dev/null
kubectl wait --for=condition=Ready pods -l app=local-path-provisioner -n local-path-storage --timeout=60s 2>/dev/null

# Install k9s
curl -sL https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_Linux_amd64.tar.gz | tar xz -C /usr/local/bin k9s 2>/dev/null

# ============================================================
# BEGINNER (warmup — all fixable with kubectl edit/patch)
# ============================================================

# provisioning: Secret exists but with wrong name
# Deployment references "db-credentials" but the secret is named "database-creds"
kubectl create namespace provisioning
kubectl create secret generic database-creds \
    --from-literal=DB_HOST=postgres.internal \
    --from-literal=DB_PASSWORD=changeme \
    -n provisioning
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: account-provisioner
  namespace: provisioning
spec:
  replicas: 1
  selector:
    matchLabels:
      app: account-provisioner
  template:
    metadata:
      labels:
        app: account-provisioner
    spec:
      containers:
        - name: app
          image: nginx:1.25
          envFrom:
            - secretRef:
                name: db-credentials
          ports:
            - containerPort: 80
EOF

# call-analytics: OOMKilled — container tries to allocate 128Mi but limit is 32Mi
kubectl create namespace call-analytics
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-aggregator
  namespace: call-analytics
spec:
  replicas: 1
  selector:
    matchLabels:
      app: metrics-aggregator
  template:
    metadata:
      labels:
        app: metrics-aggregator
    spec:
      containers:
        - name: app
          image: nginx:1.25
          command: ["/bin/sh", "-c"]
          args:
            - |
              echo "Starting metrics aggregation..."
              # Simulate loading call data into memory
              head -c 128M /dev/urandom > /dev/null 2>&1 &
              dd if=/dev/zero bs=1M count=128 of=/tmp/buffer 2>/dev/null
              nginx -g 'daemon off;'
          resources:
            requests:
              cpu: 50m
              memory: 32Mi
            limits:
              cpu: 100m
              memory: 32Mi
          ports:
            - containerPort: 80
EOF

# cdr-storage: PVC exists but deployment references wrong claimName
kubectl create namespace cdr-storage
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cdr-data
  namespace: cdr-storage
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cdr-writer
  namespace: cdr-storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cdr-writer
  template:
    metadata:
      labels:
        app: cdr-writer
    spec:
      containers:
        - name: app
          image: nginx:1.25
          volumeMounts:
            - name: data
              mountPath: /data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: cdr-data-old
EOF

# ============================================================
# INTERMEDIATE (core troubleshooting — the real differentiators)
# All fixable with kubectl edit/patch/scale/label
# ============================================================

# admin-portal: Service selector mismatch
kubectl create namespace admin-portal
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portal-ui
  namespace: admin-portal
spec:
  replicas: 2
  selector:
    matchLabels:
      app: portal-ui
  template:
    metadata:
      labels:
        app: portal-ui
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: portal-ui-svc
  namespace: admin-portal
spec:
  selector:
    app: portal-ui-v2
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# call-routing: Wrong targetPort in Service
kubectl create namespace call-routing
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: route-engine
  namespace: call-routing
spec:
  replicas: 2
  selector:
    matchLabels:
      app: route-engine
  template:
    metadata:
      labels:
        app: route-engine
    spec:
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: route-engine-svc
  namespace: call-routing
spec:
  selector:
    app: route-engine
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
EOF

# number-porting: Namespace quota exceeded
kubectl create namespace number-porting
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pod-limit
  namespace: number-porting
spec:
  hard:
    pods: "2"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: port-processor
  namespace: number-porting
spec:
  replicas: 3
  selector:
    matchLabels:
      app: port-processor
  template:
    metadata:
      labels:
        app: port-processor
    spec:
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

# media-processing: Node affinity — no matching node
kubectl create namespace media-processing
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: transcoder
  namespace: media-processing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: transcoder
  template:
    metadata:
      labels:
        app: transcoder
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: disktype
                    operator: In
                    values:
                      - ssd
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

# ============================================================
# ADVANCED (deeper debugging — separates senior from mid)
# ============================================================

# service-mesh: DNS broken — pod dnsPolicy set to None with no dnsConfig
kubectl create namespace service-mesh
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: consul-agent
  namespace: service-mesh
spec:
  replicas: 1
  selector:
    matchLabels:
      app: consul-agent
  template:
    metadata:
      labels:
        app: consul-agent
    spec:
      dnsPolicy: "None"
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
          command: ["/bin/sh", "-c"]
          args:
            - |
              echo "Resolving upstream dependencies..."
              while ! nslookup kubernetes.default.svc.cluster.local; do
                echo "DNS lookup failed, retrying..."
                sleep 5
              done
              nginx -g 'daemon off;'
EOF

sleep 5
touch /tmp/.setup-complete
