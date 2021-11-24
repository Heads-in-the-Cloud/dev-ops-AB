#!/bin/sh
docker-compose -f ../db.yml up -d

cat <<EOF | kind create cluster --name utopia --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
kubectl create secret generic db-info \
  --from-file=db-user=../secrets/mysql_username.txt \
  --from-file=db-url=../secrets/mysql_url.txt \
  --from-file=db-password=../secrets/mysql_password.txt
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
kubectl create namespace utopia-ns
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
kubectl apply -f .
