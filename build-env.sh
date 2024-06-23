IMAGE="${IMAGE:-new-env:latest}"
podman build . -t $IMAGE -f new-env.Dockerfile
