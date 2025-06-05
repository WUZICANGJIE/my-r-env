#!/bin/bash
# Pull and run R environment from Docker Hub

set -e

DOCKERHUB_USERNAME="wuzicangjie"
IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env:latest"
RENV_CACHE_HOST="$HOME/.cache/R/renv"

mkdir -p "$RENV_CACHE_HOST"
docker pull "$IMAGE_NAME"

docker run -it --rm \
    -e "RENV_PATHS_CACHE=/renv/cache" \
    -v "$RENV_CACHE_HOST:/renv/cache" \
    -v "$(pwd):/project" \
    -w /project \
    "$IMAGE_NAME"
