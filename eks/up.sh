#!/bin/sh

# Create IAM Policy: TODO add to terraform?
#curl -O "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json"
#aws iam create-policy --policy-name ALBIngressControllerIAMPolicy --policy-document file://iam-policy.json
#rm iam-policy.json

# https://aws.amazon.com/blogs/containers/using-alb-ingress-controller-with-amazon-eks-on-fargate/

VPC_ID=
SUBNET_IDS=
AWS_REGION=
HOSTED_ZONE_ID=
SUBDOMAIN=
CLUSTER_NAME='ab'

# Create Cluster
if eksctl create cluster \
  --name=$CLUSTER_NAME \
  --vpc-private-subnets=$SUBNET_IDS \
  --region=$AWS_REGION \
  --fargate \
  --alb-ingress-access
then

  # Approve cluster to associate IAM OpenID Connect Provider
  eksctl utils associate-iam-oidc-provider --cluster=$CLUSTER_NAME --approve

  AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

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
  #kubectl create secret generic db-info \
  #  --from-file=db-user=../secrets/mysql_username.txt \
  #  --from-file=db-url=../secrets/mysql_url.txt \
  #  --from-file=db-password=../secrets/mysql_password.txt
  #kubectl create secret generic jwt-secret \
  #  --from-file=jwt-secret=../secrets/jwt_secret.txt

  # Apply config files
  # TODO logging: -f aws-logging-cloudwatch-configmap.yml

  sed -e 's/$AWS_REGION/'"$AWS_REGION"'/g' -e 's/$AWS_ACCOUNT_ID/'"$AWS_ACCOUNT_ID"'/g' api-deployment.yml | kubectl apply -f -

  kubectl apply -f api-service.yml -f ingress.yml

  # Wait for ELB addresk to be assigned to ingress
  ## https://stackoverflow.com/questions/70108499/kubectl-wait-for-service-on-aws-eks-to-expose-elastic-load-balancer-elb-addres
  ALB_ADDRESS=$(timeout 90s bash -c 'until kubectl get ingress utopia-ingress --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}'; do : ; done')

# Create Route 53 record
  aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$SUBDOMAIN'","Type":"CNAME","TTL":20,"ResourceRecords":[{"Value":"'$ALB_ADDRESS'"}]}}]}' \
    > /dev/null 2>&1
fi
