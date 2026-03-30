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

# Ensure Helm is available
if ! command -v helm &>/dev/null; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 2>/dev/null
fi

# ============================================================
# BEGINNER SCENARIOS
# ============================================================

# cdr-storage: PVC with nonexistent StorageClass
kubectl create namespace cdr-storage
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cdr-data
  namespace: cdr-storage
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-ssd
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
            claimName: cdr-data
EOF

# provisioning: Missing secret reference
kubectl create namespace provisioning
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

# call-analytics: OOMKilled (4Mi limit)
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
          resources:
            requests:
              cpu: 50m
              memory: 4Mi
            limits:
              cpu: 100m
              memory: 4Mi
          ports:
            - containerPort: 80
EOF

# alerting: Missing ConfigMap mount
kubectl create namespace alerting
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alert-dispatcher
  namespace: alerting
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alert-dispatcher
  template:
    metadata:
      labels:
        app: alert-dispatcher
    spec:
      containers:
        - name: app
          image: nginx:1.25
          envFrom:
            - configMapRef:
                name: pagerduty-config
          ports:
            - containerPort: 80
EOF

# ============================================================
# INTERMEDIATE SCENARIOS
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

# sbc-proxy: Bad Helm image tag
kubectl create namespace sbc-proxy
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null
helm repo update 2>/dev/null
helm upgrade --install edge-proxy bitnami/nginx \
  --namespace sbc-proxy \
  --set image.tag=99.99.99-doesnotexist \
  --wait=false 2>/dev/null

# registration: Liveness probe wrong port
kubectl create namespace registration
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reg-service
  namespace: registration
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reg-service
  template:
    metadata:
      labels:
        app: reg-service
    spec:
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
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

# directory: Readiness probe failing (pod Running but 0/1 Ready)
kubectl create namespace directory
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lookup-service
  namespace: directory
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lookup-service
  template:
    metadata:
      labels:
        app: lookup-service
    spec:
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /ready
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 3
            failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: lookup-service-svc
  namespace: directory
spec:
  selector:
    app: lookup-service
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
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
# ADVANCED SCENARIOS
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

# call-recording: StatefulSet with wrong PVC accessMode
# local-path-provisioner only supports ReadWriteOnce — ReadWriteMany will fail
kubectl create namespace call-recording
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: recording-writer
  namespace: call-recording
spec:
  serviceName: recording-writer
  replicas: 1
  selector:
    matchLabels:
      app: recording-writer
  template:
    metadata:
      labels:
        app: recording-writer
    spec:
      containers:
        - name: app
          image: nginx:1.25
          volumeMounts:
            - name: recording-data
              mountPath: /var/recordings
  volumeClaimTemplates:
    - metadata:
        name: recording-data
      spec:
        storageClassName: local-path
        accessModes: ["ReadWriteMany"]
        resources:
          requests:
            storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: recording-writer
  namespace: call-recording
spec:
  clusterIP: None
  selector:
    app: recording-writer
  ports:
    - port: 80
EOF

sleep 5
touch /tmp/.setup-complete
