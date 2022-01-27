#!/bin/sh

region=us-west-2
s3_bucket=ab-utopia
#tf_s3_bucket=tf-plans-ab

#aws s3api create-bucket \
#  --bucket $s3_bucket \
#  --region $region \
#  --create-bucket-configuration LocationConstraint=$region

aws s3 cp --recursive mysql/ s3://$s3_bucket/mysql

#aws s3api create-bucket \
#  --bucket $tf_s3_bucket \
#  --region $region \
#  --create-bucket-configuration LocationConstraint=$region

#aws s3api delete-bucket --bucket $db_s3bucket --region $region
#aws s3api delete-bucket --bucket $tf_s3bucket --region $region
