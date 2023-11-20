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

# Required environmentals
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Install packages from outside world
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    gdb \
    ninja-build \
    gettext \
    cmake \
    unzip \
    curl \
    git \
    ca-certificates \
    zsh

# Setup our user
RUN userdel -r ubuntu
RUN groupadd -g $GID $USER
RUN useradd -m -d $HOME -s /bin/zsh -u $UID -g $GID $USER

# Setup zsh customizations
COPY software/ohmyzsh $OHMYZSHHOME
COPY themes/zsh/powerlevel10k $OHMYZSHHOME/custom/themes/powerlevel10k
COPY dotfiles/zsh/rc.zsh $HOME/.zshrc
COPY dotfiles/zsh/p10k.zsh $HOME/.p10k.zsh

USER $USER
WORKDIR $HOME
