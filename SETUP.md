# Setup

Host setup for the training app. Install the [prerequisites](README.md#prerequisites) first.

**Contents:** [Host vs. dev container](#host-vs-dev-container) · [Host setup](#host-setup) · [Connecting the app to Floci](#connecting-the-app-to-floci) · [AWS CLI profile for Floci](#aws-cli-profile-for-floci) · [Troubleshooting](#troubleshooting) · [Full reset](#full-reset)

## Host vs. dev container

The dev container has no Docker CLI, Pulumi or AWS CLI. Everything in this file runs **on the host**:

| On the host (this file) | In the [dev container](.devcontainer/README.md) |
|---|---|
| `docker compose`, `./gradlew bootBuildImage`, `pulumi`, `aws ...`, editing the app config after `pulumi up` | `./gradlew bootRun` / `mise run boot:*`, `./gradlew test`, `karate run ...` |

Pulumi must run on the host: the ECS task mounts `keys/` by its absolute host path, which has to match the `${PWD}/keys` that Floci allows in [docker-compose.yaml](docker-compose.yaml). The project folder is bind-mounted into the dev container, so config files edited on the host are picked up there as well.

## Host setup

Run all commands from the repository root unless a `cd` says otherwise.

**1. Install the host tools** from [mise.toml](mise.toml) (Java 21, Node, Dev Container CLI):

```bash
mise trust
mise install
```

**2. Generate the signing keys.** The embedded authorization server signs its JWTs with an RSA key pair loaded from `keys/` (`app.security.signing-key.*` in [application-security.properties](src/main/resources/application-security.properties)). The folder is git-ignored, so a fresh clone has no keys and the app will not start. The loader expects PEM: a PKCS#8 private key (`BEGIN PRIVATE KEY`) and an X.509 public key (`BEGIN PUBLIC KEY`), which is what these commands produce:

```bash
mkdir -p keys
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out keys/auth-signing.key
openssl rsa -in keys/auth-signing.key -pubout -out keys/auth-signing.pub
```

**3. Start Floci and the observability stack.** Must run from the repo root: Floci only lets ECS tasks mount `${PWD}/keys`.

```bash
docker compose up -d
```

**4. Build the app image** for ECS. The name comes from `group` and `version` in [gradle.properties](gradle.properties): `<group, dots replaced by dashes>/training-app:<version>`, e.g. `eu-meiyu/training-app:0.1.0`. Pulumi derives the same name from that file.

```bash
./gradlew bootBuildImage
```

**5. Provision the infrastructure** (RDS Postgres, Cognito user pool + test users, ECS service):

```bash
cd iac
npm install
pulumi login --local                     # note: switches your Pulumi login globally, state lives in ~/.pulumi
export PULUMI_CONFIG_PASSPHRASE=""
pulumi stack select --create dev         # Pulumi.dev.yaml only applies to the stack "dev"
pulumi up
```

#### Linux hosts

Docker Desktop provides `host.docker.internal` and shares `/Users` with its VM. Docker Engine on Linux does not provide them. This section applies to Docker Engine. If you use Docker Desktop, skip this section.

`hostAlias` is the address that the ECS task uses to reach services on the host. These services are Floci on port `4566`, Postgres on port `7001` and the OTel collector on port `4318`. The default value is `host.docker.internal`. That name does not work in a Floci task on Docker Engine.

1. Start the stack as described in step 3. Run `docker compose up -d` from the repository root.
2. Run `pulumi up` as described in step 5.
3. Verify the ECS app:

   ```bash
   curl -fsS http://localhost:8081/actuator/health | jq
   ```

   If the app reports `UP`, skip the rest of this section.

If the ECS task cannot reach the host services, set `hostAlias`. Find the address that containers use to reach the host:

```bash
docker network inspect bridge --format '{{(index .IPAM.Config 0).Gateway}}'
```

The command prints a gateway address, for example `172.17.0.1`. Set that address in the `dev` stack. Run these commands in `iac/`:

```bash
export PULUMI_CONFIG_PASSPHRASE=""
pulumi config set hostAlias <gateway-ip>
pulumi up
```

`keysDir` is the absolute host path of `keys/`. Floci allows ECS mounts only under the path that Compose used in step 3 (`${PWD}/keys`). By default, Pulumi computes `<repo>/keys`. This value matches `${PWD}/keys` when you start Compose from the repository root. Set `keysDir` only when the keys mount fails:

```bash
pulumi config set keysDir "$(cd .. && pwd)/keys"
pulumi up
```

Run the `keysDir` command in `iac/`. The `cd ..` part refers to the repository root. Each `pulumi config set` command writes the value to [Pulumi.dev.yaml](iac/Pulumi.dev.yaml).

**6. Update the app config with the generated values.** The IDs committed in [application-security.properties](src/main/resources/application-security.properties) and the port in [application-jpa.properties](src/main/resources/application-jpa.properties) are only examples from an earlier stack: a fresh `pulumi up` creates a new user pool, client and possibly another Postgres port. Still in `iac/`:

```bash
pulumi stack output --json --show-secrets   # clientId, clientSecret, userPoolId, dbPort, ...
cd ..
```

Then update the files listed in [Connecting the app to Floci](#connecting-the-app-to-floci). The ECS app needs none of this: its settings are filled from the stack outputs automatically.

**7. Verify the host stack.** The ECS app (same image, port 8081) runs on the stack you just created, so it checks Floci, Postgres and Cognito end to end:

```bash
docker compose ps                                       # floci, floci-proxy, otel-collector, prometheus, tempo, grafana
curl -fsS http://localhost:8081/actuator/health | jq    # ECS app; may take a minute after pulumi up
```

Open http://localhost:8081/training and http://localhost:3000 (Grafana).

**8. Continue in the dev container.** Create and open it as described in [.devcontainer/README.md](.devcontainer/README.md#getting-started), then run the app there with `mise run boot:start` and open http://localhost:8080/training. Log in at http://localhost:8080/secured-endpoint/user-info with a user from [iac/users.json](iac/users.json) (e.g. `jane.doe` / `Password123!`).

## Connecting the app to Floci

The app on port 8080 (in the dev container or on the host) reads Floci values from the properties files. After every fresh `pulumi up`, update them on the host from `pulumi stack output --json --show-secrets` (run in `iac/` with `PULUMI_CONFIG_PASSPHRASE=""`), then restart the app.

| Property / setting | File | Stack output |
|---|---|---|
| `spring.security.oauth2.client.registration.sso.client-id` | [application-security.properties](src/main/resources/application-security.properties) | `clientId` |
| `spring.security.oauth2.client.registration.sso.client-secret` | [application-security.properties](src/main/resources/application-security.properties) | `clientSecret` |
| `spring.security.oauth2.client.provider.cognito.issuer-uri` = `http://localhost:4566/<userPoolId>` | [application-security.properties](src/main/resources/application-security.properties) | `userPoolId` |
| `spring.datasource.url` = `jdbc:postgresql://localhost:<dbPort>/training-db` | [application-jpa.properties](src/main/resources/application-jpa.properties) | `dbPort` |
| `HOST_FORWARD_PORTS`: replace `7001` with `<dbPort>` (only if it differs) | [.devcontainer/start-relay.sh](.devcontainer/start-relay.sh) | `dbPort` |

Single values: `pulumi stack output dbPort`, `pulumi stack output clientSecret --show-secrets`.

The relay in the dev container only reads `HOST_FORWARD_PORTS` when it starts. After changing it, restart the dev container (or, inside it: `pkill gost && bash .devcontainer/start-relay.sh`).

## AWS CLI profile for Floci

Optional, useful to inspect what Pulumi created. `~/.aws/config`:

```ini
[profile floci]
region = us-east-1
output = json
endpoint_url = http://localhost:4566
```

`~/.aws/credentials`:

```ini
[floci]
aws_access_key_id = test
aws_secret_access_key = test
```

Examples:

```bash
aws cognito-idp list-user-pools --max-results 10 --profile floci
aws rds describe-db-instances --profile floci \
  --query "DBInstances[*].[DBInstanceIdentifier,Endpoint.Port]" --output table
aws ecs list-tasks --cluster training-cluster --profile floci
```

## Troubleshooting

| Problem | Fix |
|---|---|
| App does not start: signing key file not found | Generate `keys/` ([step 2](#host-setup)) |
| Login fails or redirect error after a new `pulumi up` | Client ID, secret or pool ID in `issuer-uri` are stale, see [Connecting the app to Floci](#connecting-the-app-to-floci) |
| Postgres connection refused | Port differs from 7001: `pulumi stack output dbPort`, then update the datasource URL and the dev container relay ([Connecting the app to Floci](#connecting-the-app-to-floci)) |
| `pulumi up` asks for a passphrase or a stack | `export PULUMI_CONFIG_PASSPHRASE=""` and `pulumi stack select --create dev` |
| ECS task fails to mount `keys/` | `pulumi up` was not run on the host, or `docker compose up -d` was not run from the repo root (`keysDir` must match `${PWD}/keys`) |
| Rebuilt image not used by ECS | Bump `version` in [gradle.properties](gradle.properties), run `./gradlew bootBuildImage` and `pulumi up`: the new tag creates a new task definition. A rebuild under the same version keeps the tag, so the service is not updated; then try `aws ecs update-service --cluster training-cluster --service training-app --force-new-deployment --profile floci` (not verified on Floci) |
| Port 8080 already in use | The dev container publishes 8080; don't run `bootRun` on the host and in the container at the same time |

For problems inside the dev container (relay, ports 4566/7001/4318), see [.devcontainer/README.md](.devcontainer/README.md#troubleshooting).

## Full reset

Floci keeps its state in `./data` (`FLOCI_STORAGE_MODE: hybrid`, git-ignored):

```bash
(cd iac && PULUMI_CONFIG_PASSPHRASE="" pulumi destroy)   # while Floci still runs
docker compose down
rm -rf data/
```

Then continue with [Host setup](#host-setup) from step 3. If `data/` was already deleted, run `pulumi refresh` in `iac/` first so Pulumi forgets the resources that no longer exist, then `pulumi up`.
