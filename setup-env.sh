#/bin/bash

set -e


PATH_TO_REPO="${PATH_TO_REPO:-$PWD}"
HOME_CONFIG="${HOME_CONFIG:-$HOME/.config}"
NVIM_CONFIG="${NVIM_CONFIG:-$HOME_CONFIG/nvim}"
CLANGD_CONFIG="${CLANGD_CONFIG:-$HOME_CONFIG/clangd}"

# Create folders for what we're symlinking if the base roots don't already exist
echo "Creating base folders for things that will be symlinked from the dev-env repo"

mkdir -p $NVIM_CONFIG
mkdir -p $CLANGD_CONFIG

# Symlink all files that will be mounted to local locations

echo "Symlinking files in the dev repository..."
echo "This will allow for changes in local or in a container to be synced by to the repository easily"

# Dotfiles
ln -s $PATH_TO_REPO/dotfiles/zsh/zshrc $HOME/.zshrc
ln -s $PATH_TO_REPO/dotfiles/zsh/p10k.zsh $HOME/.p10k.zsh
ln -s $PATH_TO_REPO/dotfiles/zsh/aliases $HOME/.aliases
ln -s $PATH_TO_REPO/dotfiles/tmux/tmux.conf $HOME/.tmux.conf
ln -s $PATH_TO_REPO/dotfiles/clangd/config.yaml $CLANGD_CONFIG/config.yaml
ln -s $PATH_TO_REPO/dotfiles/nvim/open-env $NVIM_CONFIG

