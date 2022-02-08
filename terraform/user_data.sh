#!/bin/sh

yum update -y
yum install -y mysql

aws s3 cp --recursive s3://${s3_bucket}/mysql .
mysql -h "${db_host}" -u "${db_root_username}" -p"${db_root_password}" << EOF
$(cat schema.sql)

-- Microservice user
CREATE USER '${db_username}'@'%' IDENTIFIED BY '${db_password}';
GRANT SELECT, INSERT, UPDATE, DELETE ON utopia.* TO '${db_username}'@'%';
FLUSH PRIVILEGES;

$(cat data.sql)
EOF
rm *.sql

poweroff
