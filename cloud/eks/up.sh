#!/bin/sh

# https://aws.amazon.com/blogs/containers/using-alb-ingress-controller-with-amazon-eks-on-fargate/

export AWS_REGION='us-west-2'
export CLUSTER_NAME='ab'
export VPC_ID=vpc-0f3dce67ace642302
export SUBNET_IDS=subnet-076b83db40e1a306b,subnet-0dd19084a6dde6ecd

# Create Cluster
eksctl create cluster --name=$CLUSTER_NAME --region=$AWS_REGION --fargate --vpc-private-subnets=$SUBNET_IDS

# Approve cluster to associate IAM OpenID Connect Provider
eksctl utils associate-iam-oidc-provider --cluster=$CLUSTER_NAME --approve

# Create IAM Policy
#curl -O "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json"
#aws iam create-policy --policy-name ALBIngressControllerIAMPolicy --policy-document file://iam-policy.json
#rm iam-policy.json

export STACK_NAME=eksctl-$CLUSTER_NAME-cluster
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

# Setup ALB Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml

eksctl create iamserviceaccount \
       --name=alb-ingress-controller \
       --namespace=kube-system \
       --cluster=$CLUSTER_NAME \
       --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/ALBIngressControllerIAMPolicy \
       --override-existing-serviceaccounts \
       --approve

curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml" \
     | sed "s/# - --cluster-name=devCluster/- --cluster-name=$CLUSTER_NAME/g" \
     | sed "s/# - --aws-vpc-id=vpc-xxxxxx/- --aws-vpc-id=$VPC_ID/g" \
     | sed "s/# - --aws-region=us-west-1/- --aws-region=$AWS_REGION/g" \
     | kubectl apply -f -

# Import Secrets
kubectl create secret generic db-info \
  --from-file=db-user=../secrets/mysql_username.txt \
  --from-file=db-url=../secrets/mysql_url.txt \
  --from-file=db-password=../secrets/mysql_password.txt
kubectl create secret generic jwt-secret \
  --from-file=jwt-secret=../secrets/jwt_secret.txt

# Apply config files
kubectl apply -f api-service.yml -f ingress.yml -f aws-logging-cloudwatch-configmap.yml

sed -e 's/$AWS_REGION/'"$AWS_REGION"'/g' -e 's/$AWS_ACCOUNT_ID/'"$AWS_ACCOUNT_ID"'/g' api-deployment.yml | kubectl apply -f -
