#!/bin/sh
kubectl create secret generic db-user-creds --from-file=./mysql_username.txt --from-file=./mysql_password.txt
kubectl create secret generic db-secrets --from-file=./mysql_username.txt --from-file=./mysql_password.txt --from-file=./mysql_root_password.txt
