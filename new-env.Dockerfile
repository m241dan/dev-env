# Stretch goal of this whole thing would be to abstract the parts of this that depend on the base image, and allow to detect what the base image is and then do the right thing (ie, apt for ubuntu, yum for redhat, etc) and bail out gracefully if the base distro is not configured
# Setup the base image
ARG OS=ubuntu
ARG OS_VER=24.04
ARG BUILD_IMAGE=build-env
ARG BUILD_IMAGE_VER=latest

FROM $OS:$OS_VER as build-env

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    clang \
    clangd \
    cmake \
    gdb \
    ninja-build \
    make \
    python3 \
    python3-pip \
    python3-venv \
    rustc \
    cargo \
    golang-go \
# some basic utilities
    unzip \
    curl 

# COPY software/gcc /gcc
# COPY software/llvm-project /llvm-project
# 
# RUN mkdir -p /gcc/objdir && cd /gcc/objdir && /gcc/configure --disable-multilib && make -j$(nproc) && make install && cd / && rm -rf /gcc
# RUN mkdir -p /llvm-project/build && cmake -S llvm -B /llvm-project/build -G Ninja -DLLVM_ENABLE_PROJECTS="clang;clang-extra-tools" /llvm-project && cmake --build /llvm-project/build && cmake --build /llvm-project/build --target install && rm -rf /llvm-project

FROM build-env as dev-env

# User stuff
ARG USER=dkoris
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
ARG OHMYZSHHOME=$HOME/.oh-my-zsh
ARG TMUX_HOME=$HOME/.tmux
ARG TMUX_PLUGINS=$HOME/.tmux_plugins
ARG ZSH_CUSTOM=$HOME/.zsh_plugins
ARG ZSH_THEMES=$ZSH_CUSTOM/themes
# Software versions
ARG LAZYGIT_VERSION=0.42.0
ARG LAZYDOCKER_VERSION=0.23.3
ARG CLANGD_VERSION=18.1.3
ARG LUALS_VERSION=3.9.1
ARG NEOCMAKE_VERSION=v0.6.26
ARG ZSH_VERSION=5.9 
ARG RIPGREP_VERSION=14.1.0
ARG BAT_VERSION=0.24.0
ARG BAT_EXTRAS_VERSION=2024.06.01
ARG GDB_VERSION=14.2
ARG NEOVIM_VERSION=0.10.0
ARG TMUX_VERSION=3.4
ARG ELIXIR_LSP_VERSION=v0.23.0

ENV TERM=xterm-256color

#
# Install package manager things
#

# Setup keyring for github cli
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
   && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
   && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# The actual install
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    git \
    ca-certificates \
    libgmp-dev \
    libmpfr-dev \
    texinfo \
    bison \
    flex \
    libreadline-dev \
    libevent-dev \
    libncurses-dev \
    gh \
    npm \
    pkg-config

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

# Install dockerls
RUN npm install -g dockerfile-language-server-nodejs

# Install composels
RUN npm install -g @microsoft/compose-language-service

# Install elm lsp
RUN npm install -g elm elm-test elm-format @elm-tooling/elm-language-server

# Install elixir lsp
RUN curl -fsSL https://github.com/elixir-lsp/elixir-ls/releases/download/$ELIXIR_LSP_VERSION/elixir-ls-$ELIXIR_LSP_VERSION.zip | dd of=elixir-ls.zip \
    && mkdir -p $LSPS/elixir-ls && unzip elixir-ls.zip -d $LSPS/elixir-ls && chmod +x $LSPS/elixir-ls/language_server.sh 

# Install gitlab-ci-ls
RUN cargo install gitlab-ci-ls

#
# Install Terminal goodies
#

# ripgrep
RUN curl -fsSL https://github.com/BurntSushi/ripgrep/releases/download/$RIPGREP_VERSION/ripgrep-$RIPGREP_VERSION-x86_64-unknown-linux-musl.tar.gz | dd of=ripgrep.tar.gz \
    && tar -xzf ripgrep.tar.gz && mv ripgrep-$RIPGREP_VERSION-x86_64-unknown-linux-musl /opt/ripgrep && ln -sfn /opt/ripgrep/rg /opt/bin/rg && rm ripgrep.tar.gz

# fzf
COPY software/fzf /opt/fzf
RUN /opt/fzf/install

# bat
RUN curl -fsSL https://github.com/sharkdp/bat/releases/download/v$BAT_VERSION/bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz | dd of=bat.tar.gz \
    && tar -xzf bat.tar.gz && mv bat-v$BAT_VERSION-x86_64-unknown-linux-musl /opt/bat && ln -sfn /opt/bat/bat /opt/bin/bat && mv /opt/bat/autocomplete/bat.zsh /opt/bat/autocomplete/_bat && rm bat.tar.gz

# bat-extra
RUN curl -fsSL https://github.com/eth-p/bat-extras/releases/download/v$BAT_EXTRAS_VERSION/bat-extras-$BAT_EXTRAS_VERSION.zip | dd of=bat-extras.zip \
    && unzip -d /opt/bat-extras/ bat-extras.zip && rm bat-extras.zip
  
# lazygit
RUN curl -fsSL https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz | dd of=lazygit.tar.gz \
    && mkdir -p /opt/lazygit && tar -xzf lazygit.tar.gz -C /opt/lazygit && ln -sfn /opt/lazygit/lazygit /opt/bin/lazygit && rm lazygit.tar.gz

# lazydocker
RUN curl -fsSL https://github.com/jesseduffield/lazydocker/releases/download/v$LAZYDOCKER_VERSION/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz | dd of=lazydocker.tar.gz \
    && mkdir -p /opt/lazydocker && tar -xzf lazydocker.tar.gz -C /opt/lazydocker && ln -sfn /opt/lazydocker/lazydocker /opt/bin/lazydocker && rm lazydocker.tar.gz

#
# Dev Tools
#

# gdb
#RUN curl -fsSL https://ftp.gnu.org/gnu/gdb/gdb-14.2.tar.xz | dd of=gdb.tar.xz && tar -xf gdb.tar.xz && mkdir -p gdb-$GDB_VERSION/build \ 
#    && cd gdb-$GDB_VERSION/build && ../configure --with-system-readline && make -j2 && make install && cd / && rm -rf gdb-$GDB_VERSION \
#    && rm gdb.tar.xz

# neovim
RUN curl -fsSL https://github.com/neovim/neovim/releases/download/v$NEOVIM_VERSION/nvim-linux64.tar.gz | dd of=neovim.tar.gz && tar -xzvf neovim.tar.gz \
    && mv nvim-linux64 /opt/nvim && ln -sfn /opt/nvim/bin/nvim /opt/bin/nvim && rm neovim.tar.gz

# tmux
RUN curl -fsSL https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz | dd of=tmux.tar.gz && tar -xzvf tmux.tar.gz \
    && cd tmux-$TMUX_VERSION && ./configure && make -j && make install && cd .. && rm -rf tmux-3.4 tmux.tar.gz

# oh-my-zsh
COPY --chown=$USER:$USER software/ohmyzsh $OHMYZSHHOME

# Plugins
COPY --chown=$USER:$USER plugins/nvim/ $NVIM_PLUGINS
COPY --chown=$USER:$USER plugins/tmux/ $TMUX_PLUGINS
COPY --chown=$USER:$USER themes/zsh $ZSH_THEMES

# Dotfiles
COPY --chown=$USER:$USER dotfiles/nvim/open-env $NVIM_CONFIG
COPY --chown=$USER:$USER dotfiles/zsh/zshrc $HOME/.zshrc
COPY --chown=$USER:$USER dotfiles/zsh/p10k.zsh $HOME/.p10k.zsh
COPY --chown=$USER:$USER dotfiles/zsh/aliases $HOME/.aliases
COPY --chown=$USER:$USER dotfiles/tmux/tmux.conf $HOME/.tmux.conf
COPY --chown=$USER:$USER dotfiles/clangd/config.yaml $HOME/.config/clangd/config.yaml

#
# Setup scripts
#
COPY setup-env-from-container.sh /scripts
COPY setup-env-from-repo.sh /scripts
COPY run-env.sh /scripts

CMD ["tmux", "-u"]
