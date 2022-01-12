#!/bin/sh
eksctl create cluster --name=ab-cluster --region=us-west-2 --fargate --alb-ingress-access
kubectl create secret generic db-info \
  --from-file=db-user=../secrets/mysql_username.txt \
  --from-file=db-url=../secrets/mysql_url.txt \
  --from-file=db-password=../secrets/mysql_password.txt
kubectl create secret generic jwt-secret \
  --from-file=jwt-secret=../secrets/jwt_secret.txt
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
kubectl apply -f alb-ingress-controller.yaml

eksctl create fargateprofile --namespace utopia --cluster ab-cluster --region us-west-2
#kubectl wait --namespace ingress-nginx \
#  --for=condition=ready pod \
#  --selector=app.kubernetes.io/component=controller \
#  --timeout=90s
kubectl apply -f .
