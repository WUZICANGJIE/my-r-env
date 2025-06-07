#!/bin/bash
# Docker build script for renv-enabled R container

set -e

# Enable BuildKit for faster builds and cache mounts
export DOCKER_BUILDKIT=1

# Configuration
IMAGE_NAME="my-r-env"
CONTAINER_NAME="r-dev"

# Docker Hub configuration (set your username here)
DOCKERHUB_USERNAME="wuzicangjie"
DOCKERHUB_IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env"
IMAGE_TAG="latest"
FULL_DOCKERHUB_NAME="${DOCKERHUB_IMAGE_NAME}:${IMAGE_TAG}"

echo "Building Docker image with renv..."
echo "BuildKit enabled for faster builds and cache mounts..."

# Build with optimized cache settings
docker build \
    --progress=plain \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    -t "$IMAGE_NAME" \
    -f Dockerfile \
    .

echo "Image built successfully!"

echo ""
echo "================================================="
echo ">>> Build complete!"
echo "================================================="

# --- Post-Build Options ---
echo ""
echo "Choose what to do next:"
echo "1) Startup now (default)"
echo "2) Push to Docker Hub"
echo "3) Finish"
echo ""
read -p "Enter your choice (1/2/3): " -n 1 -r post_build_choice
echo ""

case $post_build_choice in
    2)
        echo ">>> Pushing to Docker Hub..."
        ./docker-push.sh
        ;;
    3)
        echo ">>> Finishing..."
        exit 0
        ;;
    1|*)
        echo ">>> Starting container..."
        ./docker-run-local.sh
        ;;
esac

echo ""
echo "================================================="
