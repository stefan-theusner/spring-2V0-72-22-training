#!/bin/bash
set -e

echo """######################################################
### About to execute dev container start script    ###
######################################################"""

####################################################################################
### Host port relay (Claude Code + opencode)
####################################################################################
# postStartCommand only runs when the IDE starts the container, so also start the relay
# from the shell rc files to cover restarts via Docker Desktop / `docker start`.
RELAY_SCRIPT="$(cd "$(dirname "$0")" && pwd)/start-relay.sh"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q "start-relay.sh" "$rc"; then
        echo "bash \"$RELAY_SCRIPT\"" >> "$rc"
    fi
done

bash "$RELAY_SCRIPT"

echo """######################################################
### Dev container start script completed           ###
######################################################"""
