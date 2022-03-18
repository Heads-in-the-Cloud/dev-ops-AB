#!/bin/sh

# The template variables are assumed to be set:
# - s3_bucket
# - db_host
# - db_root_username
# - db_root_password
# - db_username
# - db_password

yum update -y
yum install -y mysql

aws s3 cp s3://${s3_bucket}/schema.sql .

# Provision RDS instance with empty DB, user roles, and the microservice DB user
mysql -h "${db_host}" -u "${db_root_username}" -p"${db_root_password}" << EOF
$(cat schema.sql)

LOCK TABLES `user_role` WRITE;
INSERT INTO `user_role` VALUES (3,'Admin'),(1,'Employee'),(2,'Traveler');
UNLOCK TABLES;

-- Add microservice user
CREATE USER '${db_username}'@'%' IDENTIFIED WITH mysql_native_password BY '${db_password}';
GRANT SELECT, INSERT, UPDATE, DELETE ON utopia.* TO '${db_username}'@'%';
FLUSH PRIVILEGES;
EOF

rm schema.sql

poweroff
