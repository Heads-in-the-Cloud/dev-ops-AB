# Utopia Airlines Local Deployment Config

<a href='https://jenkins1.hitwc.link/job/Austin/job/Terraform/'><img src='https://jenkins1.hitwc.link/job/Austin/job/Terraform/badge/icon'></a>

This includes configurations for standing-up microservices with Docker Compose and Kubernetes along with a data producer microservice.

## DB
A Docker Compose configuration for standing-up a MySQL instance of the utopia database is available in `db.yml` file.

## Secrets
- Docker Compose: create an .env file in the root of this repository with the following contents:
```sh
DB_URL=mysql://<db-host>:<db-port>/<db-name>
DB_USERNAME=<db-username>
DB_PASSWORD=<db-password>
JWT_SECRET=<jwt-secret>
```
- Kubernetes: generate secret files by running the following shell commands:
```sh
echo -n mysql://<db-host>:<db-port>/<db-name> > secrets/mysql_url.txt
echo -n <db-username> > secrets/mysql_username.txt
echo -n <db-password> > secrets/mysql_password.txt
echo -n <jwt-secret> > secrets/jwt_secret.txt
```
- DB: run the same commands used for generating the database credentials above, along with:
```sh
echo -n <db-root-password> > secrets/mysql_root_password.txt
```
