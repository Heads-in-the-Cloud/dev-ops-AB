#!/bin/sh

region=us-west-2
db_s3_bucket=db-init-ab
#tf_s3_bucket=tf-plans-ab

aws s3api create-bucket \
  --bucket $db_s3_bucket \
  --region $region \
  --create-bucket-configuration LocationConstraint=$region

aws s3 cp mysql/*.sql s3://$db_s3_bucket

#aws s3api create-bucket \
#  --bucket $tf_s3_bucket \
#  --region $region \
#  --create-bucket-configuration LocationConstraint=$region

#aws s3api delete-bucket --bucket $db_s3bucket --region $region
#aws s3api delete-bucket --bucket $tf_s3bucket --region $region
