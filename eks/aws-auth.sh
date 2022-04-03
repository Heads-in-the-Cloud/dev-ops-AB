#!/bin/sh

echo $AWS_ACCOUNT_ID
echo $IAM_USERNAME

kubectl get configmap/aws-auth -n kube-system -o yaml |
  sed '0,/data:/s//data: \
  mapusers: | \
    \- '"userarn: arn:aws:iam::$AWS_ACCOUNT_ID:user\/$IAM_USERNAME"' \
      '"username: $IAM_USERNAME"' \
      groups: \
      \- system:masters/' |
  kubectl apply -f -
