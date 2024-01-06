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
    less \
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
    tmux \
    libc++-17-dev \
    ripgrep

# Setup our user
RUN userdel -r ubuntu
RUN groupadd -g $GID $USER
RUN useradd -m -d $HOME -s /bin/zsh -u $UID -g $GID $USER

# Create directory necessary file structure in the container
RUN mkdir -p $NVIM_LSPS

#
# Get external packages and install
#

# Get clangd
RUN curl -fsSL https://github.com/clangd/clangd/releases/download/17.0.3/clangd-linux-17.0.3.zip | dd of=clangd.zip \
    && unzip clangd.zip && mv clangd_17.0.3 $NVIM_LSPS/clangd && rm clangd.zip && ln -s $NVIM_LSPS/clangd/bin/clangd /usr/local/bin/clangd

# Get lua-language-server
RUN curl -fsSL https://github.com/LuaLS/lua-language-server/releases/download/3.7.3/lua-language-server-3.7.3-linux-x64.tar.gz | dd of=lua-language-server.tar.gz \
    && mkdir -p $NVIM_LSPS/lua-language-server && tar -xzf lua-language-server.tar.gz -C $NVIM_LSPS/lua-language-server && ln -s $NVIM_LSPS/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server

# Get neocmakelsp
RUN curl -fsSL https://github.com/Decodetalkers/neocmakelsp/releases/download/v0.6.17/neocmakelsp-x86_64-unknown-linux-gnu | dd of=neocmakelsp \
    && mkdir -p $NVIM_LSPS/neocmakelsp && mv neocmakelsp $NVIM_LSPS/neocmakelsp/ && chmod u+x $NVIM_LSPS/neocmakelsp/neocmakelsp && ln -s $NVIM_LSPS/neocmakelsp/neocmakelsp /usr/local/bin/neocmakelsp

########################
# Manual Installations #
########################

# Software
COPY software/neovim /neovim
COPY software/ohmyzsh $OHMYZSHHOME

# build any copied software that needs it
RUN cd neovim && make CMAKE_BUILD_TYPE=Release && make install

# Plugins
COPY plugins/nvim/ $NVIM_PLUGINS
COPY plugins/tmux/ $TMUX_PLUGINS

# Themes
COPY themes/zsh/powerlevel10k $OHMYZSHHOME/custom/themes/powerlevel10k
COPY themes/tmux/tmux2k $TMUX_PLUGINS/tmux2k

# Dotfiles
COPY dotfiles/nvim/open-env $NVIM_CONFIG
COPY dotfiles/zsh/zshrc $HOME/.zshrc
COPY dotfiles/zsh/p10k.zsh $HOME/.p10k.zsh
COPY dotfiles/zsh/aliases $HOME/.aliases
COPY dotfiles/tmux/tmux.conf $HOME/.tmux.conf

# Get python-lsp-server
# * Installed above via apt

# Setup git config for zsh
RUN git config --global --replace-all core.pager "less -F -X"

# Some clean-up
RUN rm /etc/apt/sources.list.d/github-cli.list # remove this so it doesn't bork up downstream containers (get some weird key error during 'apt-get update' if this is still there)

# Final settings (leave the image in the state we want to enter)
RUN chown -R $USER:$USER $HOME  # deal with anything installed / setup as root
USER $USER
WORKDIR $HOME

CMD tmux -u

