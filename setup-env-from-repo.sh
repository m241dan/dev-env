#/bin/bash

set -e

#
# Helper functions
#
symlink_folder_contents() {
    local target_dir="$1"
    local output_dir="$2"
    local type="$3"

    for plugin in "$target_dir"/*/; do
        # do some fancy bash bullshit to get the paths right
        plugin=${plugin%*/} # e.g. turn "plugins/tmux/tpm2k/" to "plugins/tmux/tpm2k"
        plugin=${plugin##*/} # e.g. turn "plugins/tmux/tpm2k" to "tpm2k"
        echo "Symlinking ${type} ${plugin}"
        ln -sfn $target_dir/$plugin $output_dir/$plugin
    done
}

#
# Real script actions starts here
#
PATH_TO_REPO="${PATH_TO_REPO:-$PWD}"
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


# Create folders for what we're symlinking if the base roots don't already exist
echo "Creating base folders for things that will be symlinked from the dev-env repo..."

mkdir -p $NVIM_SHARE
mkdir -p $CLANGD_CONFIG
mkdir -p $ZSH_CUSTOM

# Symlink all files that will be mounted to local locations

echo "Symlinking files in the dev repository..."
echo "This will allow for changes in local or in a container to be synced by to the repository easily..."

# Software
ln -sfn $PATH_TO_REPO/software/ohmyzsh $OHMYZSHHOME

# Plugins
ln -sfn $PATH_TO_REPO/plugins/nvim/ $NVIM_PLUGINS
ln -sfn $PATH_TO_REPO/plugins/tmux/ $TMUX_PLUGINS
ln -sfn $PATH_TO_REPO/themes/zsh $ZSH_THEMES

# Dotfiles
ln -sfn $PATH_TO_REPO/dotfiles/nvim/open-env $NVIM_CONFIG
ln -sfn $PATH_TO_REPO/dotfiles/zsh/zshrc $HOME/.zshrc
ln -sfn $PATH_TO_REPO/dotfiles/zsh/p10k.zsh $HOME/.p10k.zsh
ln -sfn $PATH_TO_REPO/dotfiles/zsh/aliases $HOME/.aliases
ln -sfn $PATH_TO_REPO/dotfiles/tmux/tmux.conf $HOME/.tmux.conf
ln -sfn $PATH_TO_REPO/dotfiles/clangd/config.yaml $HOME/.config/clangd/config.yaml

echo "...Done!"

