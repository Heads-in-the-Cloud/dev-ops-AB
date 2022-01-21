#!/bin/sh
AWS_REGION='us-west-2'
CLUSTER_NAME='ab'

# TODO: Delete Route 53 record

# Delete EKS Cluster
eksctl delete cluster --name=$CLUSTER_NAME --region=$AWS_REGION
