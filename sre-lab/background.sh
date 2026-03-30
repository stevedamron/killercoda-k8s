#!/bin/bash

# Wait for cluster
while ! kubectl get nodes 2>/dev/null | grep -q " Ready"; do
  sleep 2
done
sleep 5

# ============================================================
# BEGINNER SCENARIOS
# ============================================================

# data-store: PVC with nonexistent StorageClass
kubectl create namespace data-store
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: data-store
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
  name: redis-cache
  namespace: data-store
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-cache
  template:
    metadata:
      labels:
        app: redis-cache
    spec:
      containers:
        - name: redis
          image: nginx:1.25
          volumeMounts:
            - name: data
              mountPath: /data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: app-data
EOF

# payments: Missing secret reference
kubectl create namespace payments
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-processor
  namespace: payments
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payment-processor
  template:
    metadata:
      labels:
        app: payment-processor
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

# analytics: OOMKilled (4Mi limit)
kubectl create namespace analytics
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: event-aggregator
  namespace: analytics
spec:
  replicas: 1
  selector:
    matchLabels:
      app: event-aggregator
  template:
    metadata:
      labels:
        app: event-aggregator
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

# notifications: Missing ConfigMap mount
kubectl create namespace notifications
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: email-sender
  namespace: notifications
spec:
  replicas: 1
  selector:
    matchLabels:
      app: email-sender
  template:
    metadata:
      labels:
        app: email-sender
    spec:
      containers:
        - name: app
          image: nginx:1.25
          envFrom:
            - configMapRef:
                name: smtp-config
          ports:
            - containerPort: 80
EOF

# ============================================================
# INTERMEDIATE SCENARIOS
# ============================================================

# frontend: Service selector mismatch
kubectl create namespace frontend
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-ui
  namespace: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-ui
  template:
    metadata:
      labels:
        app: web-ui
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
  name: web-ui-svc
  namespace: frontend
spec:
  selector:
    app: web-ui-v2
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# checkout: Wrong targetPort in Service
kubectl create namespace checkout
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cart-service
  namespace: checkout
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cart-service
  template:
    metadata:
      labels:
        app: cart-service
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
  name: cart-service-svc
  namespace: checkout
spec:
  selector:
    app: cart-service
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
EOF

# proxy: Bad Helm image tag
kubectl create namespace proxy
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null
helm repo update 2>/dev/null
helm upgrade --install api-gateway bitnami/nginx \
  --namespace proxy \
  --set image.tag=99.99.99-doesnotexist \
  --wait=false 2>/dev/null

# backend-api: Liveness probe wrong port
kubectl create namespace backend-api
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: backend-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
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

# batch-jobs: Namespace quota exceeded
kubectl create namespace batch-jobs
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pod-limit
  namespace: batch-jobs
spec:
  hard:
    pods: "2"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: report-generator
  namespace: batch-jobs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: report-generator
  template:
    metadata:
      labels:
        app: report-generator
    spec:
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

# search: Readiness probe failing (pod Running but 0/1 Ready)
kubectl create namespace search
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: search-indexer
  namespace: search
spec:
  replicas: 1
  selector:
    matchLabels:
      app: search-indexer
  template:
    metadata:
      labels:
        app: search-indexer
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
  name: search-indexer-svc
  namespace: search
spec:
  selector:
    app: search-indexer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# compute: Node affinity — no matching node
kubectl create namespace compute
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-trainer
  namespace: compute
spec:
  replicas: 1
  selector:
    matchLabels:
      app: model-trainer
  template:
    metadata:
      labels:
        app: model-trainer
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

# discovery: DNS broken — pod dnsPolicy set to None with no dnsConfig
kubectl create namespace discovery
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-registry
  namespace: discovery
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-registry
  template:
    metadata:
      labels:
        app: service-registry
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

# logging: StatefulSet with wrong PVC accessMode (ReadWriteMany not supported)
kubectl create namespace logging
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: log-collector
  namespace: logging
spec:
  serviceName: log-collector
  replicas: 1
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
        - name: app
          image: nginx:1.25
          volumeMounts:
            - name: log-data
              mountPath: /var/log/collector
  volumeClaimTemplates:
    - metadata:
        name: log-data
      spec:
        accessModes: ["ReadWriteMany"]
        resources:
          requests:
            storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: log-collector
  namespace: logging
spec:
  clusterIP: None
  selector:
    app: log-collector
  ports:
    - port: 80
EOF

sleep 5
touch /tmp/.setup-complete
