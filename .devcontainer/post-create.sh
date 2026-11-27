#!/bin/bash
set -e

echo """######################################################
### About to start dev container post create       ###
######################################################"""

# Config files shipped with the project (.devcontainer/config)
CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)/config"

####################################################################################
### Mise setup
####################################################################################

# mise activation (the mise feature installs the binary to /usr/local/bin)
if ! grep -q "mise activate" ~/.bashrc; then
    echo 'eval "$(mise activate bash)"' >> ~/.bashrc
fi

if [ -f ~/.zshrc ] && ! grep -q "mise activate" ~/.zshrc; then
    echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
fi

# mise global config (default tools and settings)
mkdir -p ~/.config/mise
cp "$CONFIG_DIR/mise-config.toml" ~/.config/mise/config.toml

# Trust current config
mise trust

# Install tools using mise
mise install

####################################################################################
### Setup karate (installed via mise)
####################################################################################
mise exec -- karate setup --item jar

####################################################################################
### setup starship ( installed via mise)
####################################################################################
if [ -f "$CONFIG_DIR/starship.toml" ]; then
    mkdir -p ~/.config
    cp "$CONFIG_DIR/starship.toml" ~/.config/starship.toml
fi

# starship activation (the starship feature only installs the binary)
if ! grep -q "mise exec -- starship init bash" ~/.bashrc; then
    echo 'eval "$(mise exec -- starship init bash)"' >> ~/.bashrc
fi

if [ -f ~/.zshrc ] && ! grep -q "mise exec -- starship init zsh" ~/.zshrc; then
    echo 'eval "$(mise exec -- starship init zsh)"' >> ~/.zshrc
fi

####################################################################################
### Claude Code
####################################################################################
sudo mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
sudo chown -R "$(id -u):$(id -g)" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

####################################################################################
### Update opencode
####################################################################################
# Version workaround as 2.2.0 cannot be installed using the devcontainer feature
opencode upgrade --major

####################################################################################
### gost (localhost -> host port relay, started in post-start.sh)
####################################################################################
GOST_VERSION="3.3.2"
if ! command -v gost >/dev/null; then
    curl -fsSL "https://github.com/go-gost/gost/releases/download/v${GOST_VERSION}/gost_${GOST_VERSION}_linux_$(dpkg --print-architecture).tar.gz" \
        | sudo tar -xz -C /usr/local/bin gost
fi

echo """######################################################
### Dev container post create completed            ###
######################################################"""
