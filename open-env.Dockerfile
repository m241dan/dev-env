# Stretch goal of this whole thing would be to abstract the parts of this
# that depend on the base image, and allow to detect what the base image
# is and then do the right thing (ie, apt for ubuntu, yum for redhat, etc)
# and bail out gracefully if the base distro is not configured

# Setup the base image
ARG OS=ubuntu
ARG OS_VER=23.10
FROM $OS:$OS_VER

# Customization points via commandline arg
ARG USER=korisd
ARG UID=1000
ARG GID=1000
ARG HOME=/home/$USER
ARG OHMYZSHHOME=$HOME/.oh-my-zsh
ARG NVIM_CONFIG=$HOME/.config/nvim
ARG NVIM_SHARE=$HOME/.local/share/nvim
ARG NVIM_PLUGINS=$NVIM_SHARE/plugins
ARG NVIM_LSPS=$NVIM_SHARE/lsps
ARG TMUX_HOME=$HOME/.tmux
ARG TMUX_PLUGINS=$TMUX_HOME/plugins

# Required environmentals
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Setup keyring for github cli
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
   && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
   && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install packages from outside world
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    gdb \
    ninja-build \
    gettext \
    make \
    unzip \
    curl \
    git \
    ca-certificates \
    zsh \
    python3 \
    python3-pip \
    python3-venv \
    gh \
    tmux

# Setup our user
RUN userdel -r ubuntu
RUN groupadd -g $GID $USER
RUN useradd -m -d $HOME -s /bin/zsh -u $UID -g $GID $USER

# Setup zsh customizations
COPY software/ohmyzsh $OHMYZSHHOME
COPY themes/zsh/powerlevel10k $OHMYZSHHOME/custom/themes/powerlevel10k
COPY dotfiles/zsh/zshrc $HOME/.zshrc
COPY dotfiles/zsh/p10k.zsh $HOME/.p10k.zsh
COPY dotfiles/zsh/aliases $HOME/.aliases

# Setup Neovim
COPY software/neovim /neovim
RUN cd neovim && make CMAKE_BUILD_TYPE=Release && make install
COPY dotfiles/nvim/open-env $NVIM_CONFIG
COPY plugins/nvim/ $NVIM_PLUGINS

# Setup Tmux conf
COPY dotfiles/tmux/tmux.conf $HOME/.tmux.conf
COPY plugins/tmux/ $TMUX_PLUGINS

# Create directory for LSPs
RUN mkdir -p $NVIM_LSPS

# Get clangd
RUN curl -fsSL https://github.com/clangd/clangd/releases/download/17.0.3/clangd-linux-17.0.3.zip | dd of=clangd.zip \
    && unzip clangd.zip && mv clangd_17.0.3 $NVIM_LSPS/clangd && rm clangd.zip && ln -s $NVIM_LSPS/clangd/bin/clangd /usr/local/bin/clangd

# Get lua-language-server
RUN curl -fsSL https://github.com/LuaLS/lua-language-server/releases/download/3.7.3/lua-language-server-3.7.3-linux-x64.tar.gz | dd of=lua-language-server.tar.gz \
    && mkdir -p $NVIM_LSPS/lua-language-server && tar -xzf lua-language-server.tar.gz -C $NVIM_LSPS/lua-language-server && ln -s $NVIM_LSPS/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server

# Get python-lsp-server
# * Installed above via apt

# Setup git config for zsh
RUN git config --global --replace-all core.pager "less -F -X"

# Final settings (leave the image in the state we want to enter)
RUN chown -R $USER:$USER $HOME  # deal with anything installed / setup as root
USER $USER
WORKDIR $HOME

CMD tmux -u

