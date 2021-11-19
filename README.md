# Utopia Airlines Local Deployment Config

## Prerequisites
- docker-compose: create the external secretes: db-user, db-password, and db-root-password
- kubernetes: create the secretes: db-user-creds with db-user and db-password as items along with db-root-password only containtaining the item db-root-password

## Versioning
- Container image registry and image versions specified in `.env`
