#!/bin/bash

while ! kubectl get nodes 2>/dev/null | grep -q " Ready"; do
  sleep 2
done
sleep 5

kubectl create namespace voice-gateway
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sip-proxy
  namespace: voice-gateway
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sip-proxy
  template:
    metadata:
      labels:
        app: sip-proxy
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
  name: sip-proxy-svc
  namespace: voice-gateway
spec:
  selector:
    app: sip-proxy
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

kubectl create namespace sms-router
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: message-dispatcher
  namespace: sms-router
spec:
  replicas: 1
  selector:
    matchLabels:
      app: message-dispatcher
  template:
    metadata:
      labels:
        app: message-dispatcher
    spec:
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

kubectl create namespace billing-events
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: event-collector
  namespace: billing-events
spec:
  replicas: 1
  selector:
    matchLabels:
      app: event-collector
  template:
    metadata:
      labels:
        app: event-collector
    spec:
      containers:
        - name: app
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

kubectl wait --for=condition=Available deployment --all -A --timeout=120s 2>/dev/null

touch /tmp/.setup-complete
