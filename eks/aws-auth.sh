#!/bin/sh

kubectl get configmap/aws-auth -n kube-system -o yaml |
  sed "0,/data:/s//data: \
  mapUsers: | \
    \- userarn: arn:aws:iam::$AWS_ACCOUNT_ID:user\/$IAM_USERNAME \
      username: $IAM_USERNAME \
      groups: \
      \- system:masters/" > configmap.yaml && kubectl apply -f configmap.yaml
