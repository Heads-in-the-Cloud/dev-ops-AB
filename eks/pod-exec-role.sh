#!/bin/sh

aws eks describe-fargate-profile \
    --cluster-name $CLUSTER_NAME \
    --region $AWS_REGION \
    --fargate-profile-name fp-default \
    --query 'fargateProfile.podExecutionRoleArn' |
sed -n 's/^.*role\/\(.*\)".*$/\1/ p'
