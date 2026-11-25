# Pulumi

This folder provisions the training infrastructure on Floci, the local AWS emulator. Pulumi creates RDS Postgres, a Cognito user pool with test users and an ECS service that runs the app image.

Passwords are plain text in this training project.

## Prerequisites

Install the host tools from the root [prerequisites](../README.md#prerequisites). The host shall have Docker, Pulumi CLI, AWS CLI v2, Java 21 and Node 24.21.0. Run all commands in this folder.

1. Install the Node packages:

   ```bash
   npm install
   ```

2. Use a local Pulumi backend. Pulumi stores state in `~/.pulumi`:

   ```bash
   pulumi login --local
   ```

3. Set the passphrase and select the `dev` stack:

   ```bash
   export PULUMI_CONFIG_PASSPHRASE=""
   pulumi stack select --create dev
   ```

4. Provision the resources:

   ```bash
   pulumi up
   ```

The Pulumi program uses the AWS CLI to stop stale ECS tasks after a task definition change. On Linux hosts, set `hostAlias` and `keysDir` before `pulumi up`; see [SETUP.md](../SETUP.md#linux-hosts).

## Retrieve stack outputs

Run this command in this folder:

```bash
pulumi stack output --json --show-secrets
```

The command returns output like this. Values are examples:

```json
{
  "appImageName": "eu-meiyu/training-app:0.1.7",
  "appUrl": "http://localhost:8081",
  "clientId": "<client-id>",
  "clientSecret": "<client-secret>",
  "dbAddress": "172.22.0.2",
  "dbEndpoint": "172.22.0.2:7001",
  "dbPort": 7001,
  "ecsClusterName": "training-cluster",
  "ecsServiceName": "training-app",
  "userPoolId": "us-east-1_2abe2b401"
}
```

For a single value, run `pulumi stack output dbPort` or `pulumi stack output clientSecret --show-secrets`.

## Update the host app config

The app on port 8080 reads these values from properties files. The ECS app receives them automatically through `SPRING_APPLICATION_JSON`.

Set these properties in [application-security.properties](../src/main/resources/application-security.properties):

- `spring.security.oauth2.client.registration.sso.client-id` to `clientId`.
- `spring.security.oauth2.client.registration.sso.client-secret` to `clientSecret`.
- `spring.security.oauth2.client.provider.cognito.issuer-uri` to `http://localhost:4566/<userPoolId>`.

Set this property in [application-jpa.properties](../src/main/resources/application-jpa.properties):

- `spring.datasource.url` to `jdbc:postgresql://localhost:<dbPort>/training-db`.

If `dbPort` is not `7001`, also set `HOST_FORWARD_PORTS` in [start-relay.sh](../.devcontainer/start-relay.sh). Restart the app after you change these files. Restart the relay after you change `HOST_FORWARD_PORTS`. See [SETUP.md](../SETUP.md#connecting-the-app-to-floci) for details.
