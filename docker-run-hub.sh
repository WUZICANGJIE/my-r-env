#!/bin/bash
# Docker pull and run R environment from Docker Hub

set -e

# Configuration
DOCKERHUB_USERNAME="wuzicangjie"
IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env:latest"
CONTAINER_NAME="r-dev"
RENV_CACHE_HOST="$HOME/.cache/R/renv"

# Create cache directory if it doesn't exist
mkdir -p "$RENV_CACHE_HOST"

echo "Pulling Docker image from Docker Hub..."
docker pull "$IMAGE_NAME"

# Remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Removing existing container: $CONTAINER_NAME"
    docker rm -f "$CONTAINER_NAME"
fi

echo "Running container with renv cache mounted..."
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -e "RENV_PATHS_CACHE=/renv/cache" \
    -v "$RENV_CACHE_HOST:/renv/cache" \
    -v "$(pwd):/project" \
    -w /project \
    "$IMAGE_NAME"
