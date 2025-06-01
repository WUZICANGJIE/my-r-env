#!/bin/bash
# Filename: setup.sh
# ==================
#
# This script automates the process of building the container image
# and running the Docker container.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Set Docker Hub username and desired image name here.
DOCKERHUB_USERNAME="wuzicangjie"
IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Name for local Docker container.
CONTAINER_NAME="r-env"

# --- Main Script ---
echo "================================================="
echo " R Development Environment Setup"
echo "================================================="
echo "Image to build/use: ${FULL_IMAGE_NAME}"
echo "Container to create: ${CONTAINER_NAME}"
echo "-------------------------------------------------"

# --- Step 1: Build the image from Containerfile ---
# This command builds the image locally.
echo ">>> Building local container image..."
# Build for the host's native architecture and load it for local use
docker buildx build -t "${FULL_IMAGE_NAME}" -f Containerfile . --load

# --- Step 2: (Optional) Push the image to a registry ---
# This step is for syncing your environment across machines.
read -p ">>> Do you want to push the newly built image to Docker Hub? (y/N) " choice
case "$choice" in
y | Y)
  echo ">>> Determining host architecture for tagging..."
  HOST_ARCH=$(docker system info --format '{{.Architecture}}')
  DOCKER_TAG_ARCH="" # Initialize

  if [ "$HOST_ARCH" = "x86_64" ]; then
    DOCKER_TAG_ARCH="amd64"
  elif [ "$HOST_ARCH" = "aarch64" ]; then
    DOCKER_TAG_ARCH="arm64"
  fi

  if [ -z "$DOCKER_TAG_ARCH" ]; then
    echo ">>> Error: Host architecture '$HOST_ARCH' is not supported for single-architecture push."
    echo ">>> Only x86_64 (amd64) and aarch64 (arm64) are supported for this option."
    exit 1
  else
    ARCH_SPECIFIC_TAG="${IMAGE_TAG}-${DOCKER_TAG_ARCH}"
    ARCH_SPECIFIC_IMAGE_NAME="${IMAGE_NAME}:${ARCH_SPECIFIC_TAG}"

    echo ">>> Logging in to Docker Hub..."
    docker login docker.io

    echo ">>> Tagging local image ${FULL_IMAGE_NAME} as ${ARCH_SPECIFIC_IMAGE_NAME} for pushing..."
    docker tag "${FULL_IMAGE_NAME}" "${ARCH_SPECIFIC_IMAGE_NAME}"

    echo ">>> Pushing image to ${ARCH_SPECIFIC_IMAGE_NAME}..."
    if docker push "${ARCH_SPECIFIC_IMAGE_NAME}"; then
      echo ">>> Image push complete: ${ARCH_SPECIFIC_IMAGE_NAME}"
    else
      echo ">>> Failed to push image ${ARCH_SPECIFIC_IMAGE_NAME}. Please check Docker Hub credentials and image name/tag."
      exit 1
    fi
  fi
  ;;
*)
  echo ">>> Skipping push. Using local image only."
  ;;
esac

echo "-------------------------------------------------"
echo ">>> All done!"
echo "================================================="
echo ""
echo "Next steps:"
echo "  - If you're using VS Code, ensure you have the 'Dev Containers' extension installed to connect to the container."
echo "  - You can manage your container (start, stop, view logs) using Docker Desktop or the Docker CLI."
echo "  - To start a session in the container, you can use: docker start -ai ${CONTAINER_NAME}"
echo ""
