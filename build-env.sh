set -ex

IMAGE="${IMAGE:-new-env:latest}"
if [ -z "$IMG_USER" ]; then
  IMG_USER="$USER"
fi
# podman build . -f new-env.Dockerfile --target build-env
podman build --format=docker --build-arg USER=$IMG_USER . -t $IMAGE -f new-env.Dockerfile
