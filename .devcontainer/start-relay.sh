#!/bin/bash
# Relay host ports to container localhost so tools can use 127.0.0.1 (e.g. IntelliJ MCP on 64342 for .mcp.json / opencode.jsonc).
# IntelliJ rejects requests whose Host header isn't localhost, so host.docker.internal can't be used directly.
# Add ports to HOST_FORWARD_PORTS as needed; don't list ports the container serves itself (4200, 9876, ...).
# Idempotent: does nothing if gost is already running (run `pkill gost` first to apply a changed port list).
HOST_FORWARD_PORTS="64342 4566 4318 7001"
# 64342 = Intelij Idea MCP Server
# 4566 = floci
# 4318 = otel-collector
# 7001 = postgres port
# postgres port retrieval
# aws rds describe-db-instances --profile=floci --endpoint-url http://localhost:4566 --query "DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port]" --output table

command -v gost >/dev/null || exit 0
pgrep -x gost >/dev/null && exit 0

gost_args=()
for port in $HOST_FORWARD_PORTS; do
    gost_args+=(-L "tcp://127.0.0.1:${port}/host.docker.internal:${port}")
done
( setsid nohup gost "${gost_args[@]}" >/dev/null 2>&1 & )
