# Dev container

Ubuntu 24.04 container with everything needed to build, run and test the app. Works with IntelliJ (Dev Containers) and VS Code. Floci, Postgres and the observability stack stay on the host (see [SETUP.md](../SETUP.md)).

| | |
|---|---|
| Container name | `dev-meiyu-spring-boot-cert-practice` |
| User | `vscode` |
| Workspace | `/home/vscode/workspace` (the project folder, bind-mounted from the host) |
| Published ports | `8080` (app), `9010` (debug / JMX), mapped 1:1 to the host |

## Getting started

1. **Create the container** (first time only), with one of:
   - **IntelliJ:** open `.devcontainer/devcontainer.json`, click the gutter icon and choose *Create Dev Container and Mount Sources*.
   - **VS Code:** run *Dev Containers: Reopen in Container* from the Command Palette.
   - **CLI:** `devcontainer up --workspace-folder .` (the Dev Container CLI 0.90.0 is installed by `mise install` from the root [mise.toml](../mise.toml)).
2. [post-create.sh](post-create.sh) runs automatically on creation.
3. Open a shell in the container and run once:
   ```bash
   bash .devcontainer/post-start.sh
   ```
4. Later, from the host: `mise run shell` starts the existing container and opens a shell. It only runs `docker start` / `docker exec`, so it cannot create the container (use step 1 for that).

## Host vs. container

The container has no Docker CLI, Pulumi or AWS CLI. These steps run **on the host** (see [Prerequisites](../README.md#prerequisites) and [SETUP.md](../SETUP.md)):

| On the host | In the container (or on the host) |
|---|---|
| `docker compose up -d`, `./gradlew bootBuildImage`, `pulumi up`, `aws ...` | `./gradlew bootRun` / `mise run boot:*`, `./gradlew test`, `karate run ...` |

- `keys/` is in the bind-mounted workspace, so it is shared with the host. You can generate the signing keys on either side, wherever `openssl` is available.
- Start the host stack (`docker compose up -d`, `pulumi up`) **before** `mise run boot:start` in the container. Otherwise the app cannot reach Floci and Postgres.

## Reaching host services

The app in the container connects to `localhost`, like the app on the host. [start-relay.sh](start-relay.sh) uses gost to listen on `127.0.0.1:<port>` and forward to `host.docker.internal:<port>`. That host name works through the `--add-host=host.docker.internal:host-gateway` run argument, also on Linux.

| Port | Service |
|---|---|
| 4566 | Floci |
| 4318 | OTel collector |
| 7001 | Postgres (Floci RDS) |
| 64342 | IntelliJ MCP server (optional, for coding agents) |

Why `localhost` and not `host.docker.internal` directly:
- The shared properties files use `localhost:4566`, `:7001` and `:4318`, so one config works on the host and in the container.
- Floci reports the Cognito issuer as `http://localhost:4566`, and `issuer-uri` must match it exactly.
- The IntelliJ MCP server only accepts requests with a `localhost` Host header.

If your Postgres port is not 7001, edit `HOST_FORWARD_PORTS` in [start-relay.sh](start-relay.sh) and restart the relay (see [Troubleshooting](#troubleshooting)). The port lookup is in [Connecting the app to Floci](../SETUP.md#connecting-the-app-to-floci).

Not relayed: the ECS app (8081), Grafana (3000) and Prometheus (9090) run on the host. Open them in the host browser.

**When the relay starts.** There is no `postStartCommand`: it only runs when the IDE starts the container, not on `docker start` (from `mise run shell` or Docker Desktop). Instead, the one-time `post-start.sh` adds `start-relay.sh` to `.bashrc` / `.zshrc` and starts gost. From then on, every new shell starts the relay if it is not already running. As a result, the relay only runs after a shell has been opened. If you start the app from an IDE run configuration, open a terminal in the container once first.

## What is installed

**Devcontainer features** ([devcontainer.json](devcontainer.json))

| Tool | Purpose |
|---|---|
| mise | Tool versions and project tasks (`mise run …`) |
| tmux | Runs `bootRun` in the background (`boot:*` tasks) |
| lnav | Log viewer, e.g. `lnav logs/` |
| Gradle 9.8.2, Maven 3.9.16 | Build tools (the JDK comes from mise; the project itself uses `./gradlew`) |
| Node 24.21.0 | *Optional:* only needed by Claude Code |
| Claude Code | *Optional:* coding agent |
| opencode | *Optional:* coding agent, uses Ollama on the host |

**Via mise.** Global tools come from [config/mise-config.toml](config/mise-config.toml), which is copied to `~/.config/mise/config.toml`. `mise install` also installs the project tools from the root [mise.toml](../mise.toml).

| Tool | Source | Purpose |
|---|---|---|
| Java 21 | both | JDK |
| karate-cli 0.1.9 | global | Karate launcher; post-create fetches the Karate JAR with `karate setup --item jar` |
| starship 1.27.0 | global | Shell prompt (native build for the container's architecture) |
| Node v24.21.0, devcontainer-cli 0.90.0 | root `mise.toml` | Project tool versions |

**Via [post-create.sh](post-create.sh):**
- gost 3.3.2 (port relay)
- `opencode upgrade --major`, a workaround because the opencode feature cannot install 2.2.0 (*optional*)
- creates the `CLAUDE_CONFIG_DIR` folder (*optional*)

## Configuration

| File | Purpose |
|---|---|
| [devcontainer.json](devcontainer.json) | Image, features, env vars, ports |
| [config/mise-config.toml](config/mise-config.toml) | Global mise tools and settings |
| [config/starship.toml](config/starship.toml) | Prompt config (copied to `~/.config/starship.toml`) |
| [post-create.sh](post-create.sh) | Runs once on creation: copies configs, activates mise and starship in `.bashrc` / `.zshrc`, `mise install`, Karate JAR, opencode upgrade, gost |
| [post-start.sh](post-start.sh) | Run once manually: adds the relay to `.bashrc` / `.zshrc` and starts it |
| [start-relay.sh](start-relay.sh) | Relays host ports to the container's `localhost` |

Config files are **copied**, not mounted: after editing them, rebuild the container or re-run `bash .devcontainer/post-create.sh`.

**Environment variables** (`containerEnv`):
- `GRADLE_USER_HOME=${containerWorkspaceFolder}/.gradle`: the Gradle home is inside the bind-mounted project folder. Caches survive container rebuilds and are visible from the host (see the IntelliJ entry in [Troubleshooting](#troubleshooting)).
- *Optional:* Claude Code settings (`CLAUDE_CONFIG_DIR`, no auto-update or non-essential traffic) and opencode settings (`OLLAMA_HOST`, `OPENCODE_MODEL`, `OPENCODE_API_BASE`).

## Daily use

```bash
mise run shell        # on the host: start the container and open a shell
mise run boot:start   # run the app in tmux (debug port 9010)
mise run boot:pane    # show app output
mise run boot:stop    # stop the app
lnav logs/            # browse the app logs
./gradlew test        # unit and MockMvc tests (no host stack needed)
cd karate && karate run departments.feature
```

- Open http://localhost:8080/training in the host browser. Attach a debugger to `localhost:9010`.
- `base_url` in [karate/env.yaml](../karate/env.yaml) (`http://localhost:8080`) works unchanged inside the container.
- All tasks: [mise tasks](#mise-tasks). Tests and load tests: [Testing](../ARCHITECTURE.md#testing).

### mise tasks

| Task | What |
|---|---|
| `mise run boot:start` | `bootRun` in a tmux session, debug port 9010 (not suspended) |
| `mise run boot:debug` | Like `boot:start`, but waits for a debugger on 9010 before starting |
| `mise run boot:startWithJMX` | `bootRun` with remote JMX on 9010 |
| `mise run boot:pane` | Show the app output |
| `mise run boot:stop` / `boot:restart` | Stop / restart the tmux session |
| `mise run shell` | On the host: start the dev container and open a shell |

## Troubleshooting

| Problem | Fix |
|---|---|
| Connection refused on 4566, 7001 or 4318 | Either the host stack is not up (`docker compose up -d`, `pulumi up` on the host) or the relay is not running (next rows) |
| Relay not running | Check with `pgrep -x gost`. Start it with `bash .devcontainer/start-relay.sh` (or just open a new shell) |
| Relay still not running | `start-relay.sh` exits silently if gost is not installed. Check with `command -v gost`. `post-create.sh` stops at the first error (`set -e`), so a failing step before the gost download (e.g. `opencode upgrade --major`) leaves gost missing. Re-run `bash .devcontainer/post-create.sh` |
| Postgres port is not 7001 | Update `HOST_FORWARD_PORTS` in [start-relay.sh](start-relay.sh), then `pkill gost && bash .devcontainer/start-relay.sh` |
| Port 8080 already in use | The container publishes 8080, so it cannot run alongside `./gradlew bootRun` on the host. The ECS app uses 8081 for that reason |
| IntelliJ on the host fails with `/$devcontainer.ij/…/.gradle` paths after removing the container | The shared `.gradle` folder was configured from inside the container. Reset *Settings → Build, Execution, Deployment → Build Tools → Gradle → Gradle user home* and *Gradle JVM* |
| Missing icons in the prompt | Use a Nerd Font in the terminal |
| "What's next: Try Docker Debug…" after `exit` | Docker CLI hints; disable them with `DOCKER_CLI_HINTS=false` or `"features": {"hints": "false"}` in `~/.docker/config.json` |
