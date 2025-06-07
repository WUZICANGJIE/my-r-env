#!/bin/bash
# Docker Hub push script for my-r-env container

set -e

# Configuration (should match docker-build.sh)
IMAGE_NAME="my-r-env"
DOCKERHUB_USERNAME="wuzicangjie"
DOCKERHUB_IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env"
IMAGE_TAG="latest"
FULL_DOCKERHUB_NAME="${DOCKERHUB_IMAGE_NAME}:${IMAGE_TAG}"

# Check if local image exists
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "❌ Error: Local image '$IMAGE_NAME' not found."
    echo "Please build the image first using: ./docker-build.sh"
    exit 1
fi

echo "================================================="
echo "🚀 Docker Hub Upload"
echo "================================================="
echo "Local image: $IMAGE_NAME"
echo "Docker Hub target: $FULL_DOCKERHUB_NAME"
echo ""

echo ">>> Starting automatic push to Docker Hub..."

echo ">>> Determining host architecture for tagging..."
HOST_ARCH=$(docker system info --format '{{.Architecture}}')
DOCKER_TAG_ARCH=""

if [[ "$HOST_ARCH" == "x86_64" ]]; then
    DOCKER_TAG_ARCH="amd64"
elif [[ "$HOST_ARCH" == "aarch64" ]]; then
    DOCKER_TAG_ARCH="arm64"
fi

if [[ -z "$DOCKER_TAG_ARCH" ]]; then
    echo ">>> Error: Host architecture '$HOST_ARCH' is not supported for push."
    echo ">>> Only x86_64 (amd64) and aarch64 (arm64) are supported."
    exit 1
fi

ARCH_SPECIFIC_TAG="${IMAGE_TAG}-${DOCKER_TAG_ARCH}"
ARCH_SPECIFIC_IMAGE_NAME="${DOCKERHUB_IMAGE_NAME}:${ARCH_SPECIFIC_TAG}"

echo ">>> Logging in to Docker Hub..."
docker login docker.io

echo ">>> Tagging local image ${IMAGE_NAME} as ${ARCH_SPECIFIC_IMAGE_NAME}..."
docker tag "${IMAGE_NAME}" "${ARCH_SPECIFIC_IMAGE_NAME}"

echo ">>> Pushing image to ${ARCH_SPECIFIC_IMAGE_NAME}..."
if docker push "${ARCH_SPECIFIC_IMAGE_NAME}"; then
    echo ">>> Image push complete: ${ARCH_SPECIFIC_IMAGE_NAME}"
    
    echo ">>> Also tagging as latest for this architecture..."
    docker tag "${IMAGE_NAME}" "${FULL_DOCKERHUB_NAME}"
    docker push "${FULL_DOCKERHUB_NAME}"
    
    echo ">>> Creating multi-architecture manifest..."
    if docker buildx imagetools create -t "${FULL_DOCKERHUB_NAME}" \
       "${DOCKERHUB_IMAGE_NAME}:${IMAGE_TAG}-amd64" \
       "${DOCKERHUB_IMAGE_NAME}:${IMAGE_TAG}-arm64" 2>/dev/null; then
        echo ">>> Multi-architecture manifest created successfully!"
    else
        echo ">>> Note: Multi-arch manifest creation skipped (requires both amd64 and arm64 images)"
    fi
    
    echo ""
    echo "================================================="
    echo "✅ Docker Hub Upload Complete!"
    echo "================================================="
    echo "Image available at: $FULL_DOCKERHUB_NAME"
    
else
    echo ">>> Failed to push image. Please check Docker Hub credentials."
    exit 1
fi
