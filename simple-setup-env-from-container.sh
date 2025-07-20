#!/bin/bash

# This script starts the container and copies out necessary files
# that in the future will be mounted into it. That way, any changes
# made to those files will persist between containers.

IMAGE="new-env:latest"
HOME_SHARE="${HOME_SHARE:-$HOME/.local/share}"
HOME_CONFIG="${HOME_CONFIG:-$HOME/.config}"
NVIM_CONFIG="${NVIM_CONFIG:-$HOME_CONFIG/nvim}"
NVIM_SHARE="${NVIM_SHARE:-$HOME_SHARE/nvim}"
NVIM_PLUGINS="${NVIM_PLUGINS:-$NVIM_SHARE/plugins}"
CLANGD_CONFIG="${CLANGD_CONFIG:-$HOME_CONFIG/clangd}"

echo "Starting container..."
container=$(podman run -itd --rm "$IMAGE" sleep infinity)
echo "...container running."

echo "Copying out all relevant files..."

# Plugins
podman cp "$container:"$NVIM_PLUGINS $NVIM_PLUGINS

# Dotfiles
podman cp "$container:"$NVIM_CONFIG $NVIM_CONFIG
podman cp "$container:"$HOME/.config/clangd/config.yaml $HOME/.config/clangd/config.yaml
echo "... Copying complete!"

echo "Killing container $container..."
podman kill "$container" > /dev/null
echo "...container dead. Transfer complete!"
