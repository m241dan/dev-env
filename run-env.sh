#/bin/bash

# Runs the image with a handful of necessary arguments
# Always mounts the user's home directory into the container

USERID="${USERID:-1001}"
GROUPID="${GROUPID:-1001}"
DEVIMAGE="${DEVIMAGE:-new-env:latest}"

echo "Starting dev environment with the image '$DEVIMAGE' and USER: '$USER' with UID '$USERID' and GID '$GROUPID'"
podman run -it --rm --user $USER --userns=keep-id:uid=$USERID,gid=$GROUPID -v $HOME:$HOME $DEVIMAGE
