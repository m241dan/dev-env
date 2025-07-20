# Stretch goal of this whole thing would be to abstract the parts of this that depend on the base image, and allow to detect what the base image is and then do the right thing (ie, apt for ubuntu, yum for redhat, etc) and bail out gracefully if the base distro is not configured
# Setup the base image
ARG OS=ubuntu
ARG OS_VER=24.04

FROM $OS:$OS_VER as build-env

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    clang \
    clangd \
    cmake \
    ninja-build \
    make \
    python3 \
    python3-pip \
    python3-venv \
# some basic utilities
    unzip \
    curl \
    git

FROM build-env as dev-env

# User stuff
ARG USER=korisd
ARG UID=1001

# Relevant Paths
ARG HOME=/home/$USER
ARG HOME_CONFIG=$HOME/.config
ARG HOME_SHARE=$HOME/.local/share
ARG CLANGD_CONFIG=$HOME_CONFIG/clangd
ARG LSPS=/opt/lsps
ARG NVIM_CONFIG=$HOME_CONFIG/nvim
ARG NVIM_SHARE=$HOME_SHARE/nvim
ARG NVIM_PLUGINS=$NVIM_SHARE/plugins

# Software versions
ARG CLANGD_VERSION=20.1.8
ARG LUALS_VERSION=3.15.0
ARG NEOCMAKE_VERSION=v0.8.23
ARG NEOVIM_VERSION=0.11.3

ENV TERM=xterm-256color
ENV PATH="/opt/bin:$PATH"

#
# Install package manager things
#

# setup path for third party software
RUN useradd -m -u $UID -s /bin/zsh "$USER"

# Create necessary folders
RUN mkdir -p $LSPS /opt/bin

#
# Install LSPs
#

# Install python lsp server
RUN pip3 install --break-system-packages "python-lsp-server[all]"

# Get and install clangd
RUN curl -fsSL https://github.com/clangd/clangd/releases/download/$CLANGD_VERSION/clangd-linux-$CLANGD_VERSION.zip | dd of=clangd.zip \
    && unzip clangd.zip && mv clangd_$CLANGD_VERSION $LSPS/clangd && ln -sfn $LSPS/clangd/bin/clangd /opt/bin/clangd && rm -rf clangd.zip

# Get and install lua-language-server
RUN curl -fsSL https://github.com/LuaLS/lua-language-server/releases/download/$LUALS_VERSION/lua-language-server-$LUALS_VERSION-linux-x64.tar.gz | dd of=lua-language-server.tar.gz \
    && mkdir -p $LSPS/lua-language-server && tar -xzf lua-language-server.tar.gz -C $LSPS/lua-language-server && ln -sfn $LSPS/lua-language-server/bin/lua-language-server /opt/bin/lua-language-server \
    && rm lua-language-server.tar.gz && mkdir -p $LSPS/lua-language-server/log/cache && chmod 777 $LSPS/lua-language-server/log/cache

# Get and install neocmakelsp
RUN curl -fsSL https://github.com/Decodetalkers/neocmakelsp/releases/download/$NEOCMAKE_VERSION/neocmakelsp-x86_64-unknown-linux-gnu | dd of=neocmakelsp \
    && mkdir -p $LSPS/neocmakelsp && mv neocmakelsp $LSPS/neocmakelsp/ && chmod 111 $LSPS/neocmakelsp/neocmakelsp && ln -sfn $LSPS/neocmakelsp/neocmakelsp /opt/bin/neocmakelsp

#
# Dev Tools
#

# neovim
RUN curl -fsSL https://github.com/neovim/neovim/releases/download/v$NEOVIM_VERSION/nvim-linux-x86_64.tar.gz | dd of=neovim.tar.gz && tar -xzvf neovim.tar.gz \
    && mv nvim-linux-x86_64 /opt/nvim && ln -sfn /opt/nvim/bin/nvim /opt/bin/nvim && rm neovim.tar.gz

# Plugins
COPY --chown=$USER:$USER plugins/nvim/ $NVIM_PLUGINS

# Dotfiles
COPY --chown=$USER:$USER dotfiles/nvim/open-env $NVIM_CONFIG
COPY --chown=$USER:$USER dotfiles/clangd/config.yaml $HOME/.config/clangd/config.yaml

#
# Setup scripts
#
COPY simple-setup-env-from-container.sh /scripts
COPY run-env.sh /scripts

USER $USER
