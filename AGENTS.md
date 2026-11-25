# AGENTS.md

Spring Boot 4.1 / Java 21 training app (Spring Professional 2V0-72.22 practice), backed by a local AWS emulator (Floci).

## Layout
- `src/main/java/eu/meiyu/training/` – `controller`, `service`, `repository`, `entity` (`Department`, `Card`), `dto`, `config` (+ `config/security`), `security`, `aop`, `actuator`, `bean`, `excpetion` (sic)
- `src/main/resources/application-*.properties` – one file per profile; `prod` group (default) = `config,monitoring,logging,jpa,security,otel`
- `src/test/java/...` – JUnit/MockMvc tests; `WithoutOAuth2Application` boots the app without OAuth2 auto-config
- `karate/` – API and load tests (`base_url` in `karate/env.yaml`)
- `iac/` – Pulumi (TypeScript) against Floci: RDS Postgres, Cognito user pool + test users (`users.json`), ECS service running the app image
- `iac/floci-application-properties.json` – Spring overrides for the ECS container; `${name}` placeholders are filled in `iac/index.ts`
- `docker-compose.yaml` – Floci (+ nginx proxy restyling the Cognito login page) and the observability stack (OTel collector, Prometheus, Tempo, Grafana)
- `.devcontainer/` – dev container; `mise.toml` – tool versions and `boot:*` tasks

## Commands
- Build/test: `./gradlew build`, `./gradlew test`
- Run: `./gradlew bootRun` (or `mise run boot:start` / `boot:stop`, runs in tmux)
- Container image: `./gradlew bootBuildImage` → `<group with dashes>/training-app:<version>` from `gradle.properties` (e.g. `eu-meiyu/training-app:0.1.0`); `iac/index.ts` derives the same name
- Infra: `cd iac && PULUMI_CONFIG_PASSPHRASE="" pulumi up` (local backend, `pulumi login --local`)
- Karate: `cd karate && karate run <file>.feature`

## Ports
App 8080 (host) / 8081 (ECS task) · JMX/debug 9010 · Floci 4566 · Postgres 7001 · OTLP 4318 · Grafana 3000 · Prometheus 9090 · Tempo 3200

## Conventions
- Secrets/passwords are intentionally plain text (training setup), do not "fix" that unprompted.
- Keep presentation (colors/styling) in the frontend, not in DB or API.
- Floci reports Cognito issuer as `http://localhost:4566`; containers reach host services via `host.docker.internal`.

## Documentation style
- Step-by-step guides, runbooks, and technical procedures shall use ASD-STE100 (Simplified Technical English) style by default.
- Keep sentences short. Use one idea per sentence. Use active voice. Define terms at first use. Use `shall` for requirements, `can` for ability, and `may` for permission.
- This rule does not apply to chat answers, README overviews, or architecture prose.
- Full checklist: `docs/writing-style.md`.

## Graphify
- `graphify-out/graph.json` exists: for codebase questions run `graphify query "<question>"` before any grep/search/source read, and include this rule in code-exploring subagent prompts. Read raw files only for lines the graph or an earlier read located; use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts.
- Use `graphify-out/wiki/index.md` for broad navigation; `GRAPH_REPORT.md` only for broad architecture review or when query/path/explain are insufficient.
- After code changes run `graphify update .` (AST-only, no API cost). Committed `graph.json` is rewritten whole on every build, so large PR diffs are expected — don't flag as churn or suggest skipping the rebuild/hooks.
