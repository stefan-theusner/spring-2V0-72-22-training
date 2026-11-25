# Spring Boot Training

A practice project for the **Spring Professional certification (2V0-72.22)**. It covers the exam topics in one running app, backed by a local AWS emulator (Floci), so no AWS account is needed.

**Contents:** [Key features](#key-features) · [Prerequisites](#prerequisites) · [Documentation](#documentation)

## Key features

- **Exam topics in practice:** REST controllers, Spring Data JPA, AOP aspects, custom actuator health indicators and metrics. See [Where to find each exam topic](ARCHITECTURE.md#where-to-find-each-exam-topic).
- **Study material built in:** the exam study cards are served as JSON at `/cards`, with a study page at `/training`. A `departments` API is the CRUD playground.
- **Security in three roles:** Spring Security acts as OAuth2 client (Cognito login), resource server (JWT) and authorization server (issues its own tokens).
- **Local AWS:** Floci emulates RDS Postgres, Cognito and ECS. Pulumi provisions them as code.
- **Observability and tests:** OpenTelemetry sends traces and metrics to Tempo and Prometheus, shown in Grafana. JUnit/MockMvc tests the code, Karate tests the running API.

## Prerequisites

These tools are needed **on the host**. Everything for building, running and testing the app (JDK, Gradle, tmux, Karate, lnav, ...) is installed inside the [dev container](.devcontainer/README.md).

| Tool | Why | Notes |
|---|---|---|
| Docker Desktop | Floci, observability stack, dev container, `bootBuildImage`, ECS containers | The setup relies on `host.docker.internal` and on Docker Desktop sharing `/Users` (the ECS task mounts `keys/`). On Linux, see [the Linux hint](SETUP.md#linux-hosts). |
| mise | Host tool versions | `mise install` installs Java 21 (for `bootBuildImage`), Node 24.21.0 (for the Pulumi program) and the Dev Container CLI from [mise.toml](mise.toml) |
| Pulumi CLI | Provisions RDS, Cognito, ECS on Floci | [Install](https://www.pulumi.com/docs/install/) and use a local backend (no Pulumi account) |
| openssl | Generate the signing keys | Can also be done inside the dev container |
| IntelliJ or VS Code | Open the dev container | Optional: the Dev Container CLI from `mise install` works too |
| AWS CLI v2 (>= 2.13) | Replace stale ECS tasks during `pulumi up`; *optional:* inspect Floci resources | [Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html); `endpoint_url` in a profile needs 2.13 or newer |
| curl, jq | *Optional:* verify the setup, try the token flow | |

## Documentation

- [SETUP.md](SETUP.md): host setup (signing keys, Floci and observability stack, app image, Pulumi, app config), troubleshooting and reset
- [.devcontainer/README.md](.devcontainer/README.md): dev container setup and daily use (run, debug, test the app)
- [ARCHITECTURE.md](ARCHITECTURE.md): tech stack, components, endpoints and ports, profiles, security, observability, testing, code map
- [iac/README.md](iac/README.md): Pulumi notes
- [karate/README.md](karate/README.md): load test notes
- [docs/writing-style.md](docs/writing-style.md): default style for guides, runbooks, and procedures
