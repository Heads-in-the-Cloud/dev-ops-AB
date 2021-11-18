# Utopia Airlines Local Deployment Config

## Prerequisites:
Populate mysql_root_password.txt, mysql_username.txt, and mysql_password.txt
Run `./create-kubernetes-secret.sh` prior to creating Kuberenetes pod

Suggested environment variables for Docker Compose and Kubernetes:
```sh
MYSQL_TAG=8
FLIGHTS_SPRING_API_TAG=0.0.2-SNAPSHOT
USERS_SPRING_API_TAG=0.0.2-SNAPSHOT
BOOKINGS_SPRING_API_TAG=0.0.2-SNAPSHOT
DATA_PRODUCER_TAG=0.0.2-SNAPSHOT
```

Kubernetes has the following additional environment variable for specifying the node's ip:
```sh
NODE_IP=<kuberenetes-node-ip-address>`
```
