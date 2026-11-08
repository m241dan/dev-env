#!/bin/bash

# Runs the image with a handful of necessary arguments
# Always mounts the user's home directory into the container

USERID="${USERID:-1001}"
GROUPID="${GROUPID:-1001}"
DEVIMAGE="${DEVIMAGE:-new-env:latest}"
# Named volume holding images/containers for podman inside the dev env
NESTED_VOLUME="${NESTED_VOLUME:-dev-env-containers}"

echo "Starting dev environment with the image '$DEVIMAGE' and USER: '$USER' with UID '$USERID' and GID '$GROUPID'"
podman run -itd --rm --user $USER --userns=keep-id:uid=$USERID,gid=$GROUPID -v $HOME:$HOME -p 8000:8000 \
    --device /dev/fuse --security-opt label=disable -v $NESTED_VOLUME:/var/lib/dev-env-containers \
    $DEVIMAGE
