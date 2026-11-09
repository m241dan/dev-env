set -ex

IMAGE="${IMAGE:-new-env:latest}"
# DOCKERFILE=new-env-redhat.Dockerfile IMAGE=new-env-redhat:latest ./build-env.sh
DOCKERFILE="${DOCKERFILE:-new-env.Dockerfile}"
if [ -z "$IMG_USER" ]; then
  IMG_USER="$USER"
fi
# podman build . -f new-env.Dockerfile --target build-env
podman build --format=docker --build-arg USER=$IMG_USER . -t $IMAGE -f $DOCKERFILE
