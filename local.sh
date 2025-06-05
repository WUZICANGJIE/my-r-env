#!/bin/bash
# Build and run script for renv-enabled R container

set -e

# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1

# Configuration
IMAGE_NAME="my-r-env"
CONTAINER_NAME="r-dev"
RENV_CACHE_HOST="$HOME/.cache/R/renv"

# Create cache directory if it doesn't exist
mkdir -p "$RENV_CACHE_HOST"

echo "Building Docker image with renv..."
docker build -t "$IMAGE_NAME" -f Containerfile .

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
