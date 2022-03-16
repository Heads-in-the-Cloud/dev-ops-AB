#!/bin/sh

# The following environment variables are assumed to be set:
# - VPC_CIDR_BLOCK
# - S3_BUCKET
# - DB_HOST
# - DB_ROOT_USERNAME
# - DB_ROOT_PASSWORD
# - DB_USER_USERNAME
# - DB_USER_PASSWORD

yum update -y
yum install -y mysql

aws s3 cp s3://${S3_BUCKET}/schema.sql .

# Provision RDS instance with empty DB, user roles, and the microservice DB user
mysql -h "${DB_HOST}" -u "${DB_ROOT_USERNAME}" -p"${DB_ROOT_PASSWORD}" << EOF
$(cat schema.sql)

LOCK TABLES `user_role` WRITE;
INSERT INTO `user_role` VALUES (3,'Admin'),(1,'Employee'),(2,'Traveler');
UNLOCK TABLES;

-- Add microservice user
CREATE USER '${DB_USER_USERNAME}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT SELECT, INSERT, UPDATE, DELETE ON utopia.* TO '${DB_USER_USERNAME}'@'${VPC_CIDR_BLOCK}';
FLUSH PRIVILEGES;
EOF

rm schema.sql

poweroff
