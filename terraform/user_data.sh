#!/bin/sh

# The template variables are assumed to be set:
# - s3_bucket
# - db_host
# - db_root_username
# - db_root_password
# - max_connections
# - db_username
# - db_password

yum update -y
yum install -y mysql

aws s3 cp --recursive s3://${s3_bucket}/mysql .

mysql -h "${db_host}" -u "${db_root_username}" -p"${db_root_password}" << EOF

$(cat schema.sql)
$(cat data.sql)

SET GLOBAL max_connections='${max_connections};

-- Add microservices user
CREATE USER '${db_username}'@'%' IDENTIFIED BY '${db_password}';
GRANT SELECT, INSERT, UPDATE, DELETE ON utopia.* TO '${db_username}'@'%';
FLUSH PRIVILEGES;
EOF

rm *.sql

poweroff
