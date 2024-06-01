# Stretch goal of this whole thing would be to abstract the parts of this that depend on the base image, and allow to detect what the base image
# is and then do the right thing (ie, apt for ubuntu, yum for redhat, etc)
# and bail out gracefully if the base distro is not configured

# Setup the base image
ARG OS=ubuntu
ARG OS_VER=24.04
FROM $OS:$OS_VER as build-env

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
#    flex \
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
    golang-go

# COPY software/gcc /gcc
# COPY software/llvm-project /llvm-project
# 
# RUN mkdir -p /gcc/objdir && cd /gcc/objdir && /gcc/configure --disable-multilib && make -j$(nproc) && make install && cd / && rm -rf /gcc
# RUN mkdir -p /llvm-project/build && cmake -S llvm -B /llvm-project/build -G Ninja -DLLVM_ENABLE_PROJECTS="clang;clang-extra-tools" /llvm-project && cmake --build /llvm-project/build && cmake --build /llvm-project/build --target install && rm -rf /llvm-project

FROM build-env as dev-env

ARG USER=dkoris
ARG UID=1000
ARG GID=1000
ARG HOME=/home/$USER

RUN pip3 install  --break-system-packages "python-lsp-server[all]"
    
RUN --mount=type=bind,target=/software,source=software,rw \
#     cp -r /software/fzf/ /opt/fzf && /opt/fzf/install && rm -rf /opt/fzf/.git /opt/fzf/.github \
#     && cargo install --path /software/ripgrep ripgrep \
#     && cargo install --path /software/bat --locked bat \
    go install /software/lazygit \
    && go build -C /software/lazydocker \
    && /software/gdb/configure && make -C /software/gdb && make -C /software/gdb install

