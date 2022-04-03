#!/bin/sh

kubectl get configmap/aws-auth -n kube-system -o yaml |
  sed '0,/data:/s//data: \
  mapusers: | \
    \- '"userarn: arn:aws:iam::$aws_account_id:user\/$iam_username"' \
      '"username: $iam_username"' \
      groups: \
      \- system:masters/' |
  kubectl apply -f -
