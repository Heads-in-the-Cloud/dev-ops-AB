#!/bin/sh

yum update -y
yum install -y mysql

aws s3 cp --recursive s3://${s3_bucket} .
mysql -h "${db_host}" -u "${db_root_username}" -p"${db_root_password}" << EOF
$(cat schema.sql)


$(cat data.sql)
EOF
rm *.sql

poweroff
