#!/bin/bash

# Wait for cluster
while ! kubectl get nodes 2>/dev/null | grep -q " Ready"; do
  sleep 2
done
sleep 5

# ns-storage: PVC with nonexistent StorageClass
kubectl create namespace ns-storage
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: ns-storage
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
  name: storage-app
  namespace: ns-storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage-app
  template:
    metadata:
      labels:
        app: storage-app
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
            claimName: app-data
EOF

# ns-secrets: Missing secret reference
kubectl create namespace ns-secrets
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: ns-secrets
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
        - name: api
          image: nginx:1.25
          envFrom:
            - secretRef:
                name: db-credentials
          ports:
            - containerPort: 80
EOF

# ns-resources: OOMKilled (4Mi limit)
kubectl create namespace ns-resources
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-hog
  namespace: ns-resources
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-hog
  template:
    metadata:
      labels:
        app: memory-hog
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

# ns-networking: Service selector mismatch
kubectl create namespace ns-networking
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: ns-networking
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-frontend
  template:
    metadata:
      labels:
        app: web-frontend
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
  name: web-frontend-svc
  namespace: ns-networking
spec:
  selector:
    app: web-frontend-v2
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# ns-helm: Bad image tag
kubectl create namespace ns-helm
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null
helm repo update 2>/dev/null
helm upgrade --install broken-nginx bitnami/nginx \
  --namespace ns-helm \
  --set image.tag=99.99.99-doesnotexist \
  --wait=false 2>/dev/null

# ns-probe: Liveness probe wrong port
kubectl create namespace ns-probe
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: health-api
  namespace: ns-probe
spec:
  replicas: 1
  selector:
    matchLabels:
      app: health-api
  template:
    metadata:
      labels:
        app: health-api
    spec:
      containers:
        - name: api
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

sleep 5
touch /tmp/.setup-complete
