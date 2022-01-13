#!/bin/sh
export AWS_REGION='us-west-2'
export CLUSTER_NAME='ab'

eksctl delete cluster --name=$CLUSTER_NAME --region=$AWS_REGION
