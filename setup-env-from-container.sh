#!/bin/bash

# This script starts the container and copies out necessary files
# that in the future will be mounted into it. That way, any changes
# made to those files will persist between containers.

IMAGE="new-env:latest"
OHMYZSHHOME="${OHMYZSHHOME:-$HOME/.oh-my-zsh}"
TMUX_PLUGINS="${TMUX_PLUGINS:-$HOME/.tmux_plugins}"
HOME_SHARE="${HOME_SHARE:-$HOME/.local/share}"
HOME_CONFIG="${HOME_CONFIG:-$HOME/.config}"
NVIM_CONFIG="${NVIM_CONFIG:-$HOME_CONFIG/nvim}"
NVIM_SHARE="${NVIM_SHARE:-$HOME_SHARE/nvim}"
NVIM_PLUGINS="${NVIM_PLUGINS:-$NVIM_SHARE/plugins}"
CLANGD_CONFIG="${CLANGD_CONFIG:-$HOME_CONFIG/clangd}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.zsh_plugins}"
ZSH_THEMES="${ZSH_THEMES:-$ZSH_CUSTOM/themes}"

echo "Starting container..."
container=$(podman run -itd --rm "$IMAGE" sleep infinity)
echo "...container running."

echo "Copying out all relevant files..."
# oh-my-zsh
podman cp "$container":$OHMYZSHHOME $OHMYZSHHOME

# Plugins
podman cp "$container:"$NVIM_PLUGINS $NVIM_PLUGINS
podman cp "$container:"$TMUX_PLUGINS $TMUX_PLUGINS
podman cp "$container:"$ZSH_THEMES $ZSH_THEMES

# Dotfiles
podman cp "$container:"$NVIM_CONFIG $NVIM_CONFIG
podman cp "$container:"$HOME/.zshrc $HOME/.zshrc
podman cp "$container:"$HOME/.p10k.zsh $HOME/.p10k.zsh
podman cp "$container:"$HOME/.aliases $HOME/.aliases
podman cp "$container:"$HOME/.tmux.conf $HOME/.tmux.conf
podman cp "$container:"$HOME/.config/clangd/config.yaml $HOME/.config/clangd/config.yaml
echo "... Copying complete!"

echo "Killing container $container..."
podman kill "$container" > /dev/null
echo "...container dead. Transfer complete!"
