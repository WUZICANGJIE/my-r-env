#!/bin/bash
# Filename: setup.sh
# ==================
#
# This script automates the process of building the container image
# and creating the Distrobox container from it.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Set Docker Hub username and desired image name here.
DOCKERHUB_USERNAME="wuzicangjie"
IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Name for local Distrobox container.
CONTAINER_NAME="r-env"
CONTAINER_HOME_DIR="$HOME/.distrobox-homes/$CONTAINER_NAME"


# --- Main Script ---
echo "================================================="
echo " R Development Environment Setup"
echo "================================================="
echo "Image to build/use: ${FULL_IMAGE_NAME}"
echo "Container to create: ${CONTAINER_NAME}"
echo "Container home: ${CONTAINER_HOME_DIR}"
echo "-------------------------------------------------"

# --- Step 1: Build the image from Containerfile ---
# This command builds the image locally.
echo ">>> Building local container image..."
podman build -t "${FULL_IMAGE_NAME}" -f Containerfile .

# --- Step 2: (Optional) Push the image to a registry ---
# This step is for syncing your environment across machines.
read -p ">>> Do you want to push the newly built image to Docker Hub? (y/N) " choice
case "$choice" in
  y|Y )
    echo ">>> Logging in and pushing to ${FULL_IMAGE_NAME}..."
    podman login docker.io
    podman push "${FULL_IMAGE_NAME}"
    echo ">>> Push complete."
    ;;
  * )
    echo ">>> Skipping push. Using local image only."
    ;;
esac

# --- Step 3: Create the Distrobox container ---

# Check if a container with the same name already exists and remove it to ensure a fresh start.
if podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo ">>> Found an existing container named '${CONTAINER_NAME}'. Removing it..."
    distrobox rm -f "$CONTAINER_NAME"
fi

echo ">>> Preparing container home directory..."
mkdir -p "$CONTAINER_HOME_DIR"

echo ">>> Copying .Rprofile to container home directory..."
cp .Rprofile "$CONTAINER_HOME_DIR"

echo ">>> Creating Distrobox container '${CONTAINER_NAME}'..."
distrobox-create --name "$CONTAINER_NAME" \
                 --image "$FULL_IMAGE_NAME" \
                 --home "$CONTAINER_HOME_DIR"

echo
echo "================================================="
echo "🎉 Success! Your R environment is ready."
echo "================================================="

# --- Step 4: (Optional) Start the container ---
read -p ">>> Do you want to start the container '${CONTAINER_NAME}' now? (y/N) " start_choice
case "$start_choice" in
  y|Y )
    echo ">>> Starting container '${CONTAINER_NAME}'..."
    distrobox enter "$CONTAINER_NAME"
    ;;
  * )
    echo ">>> To enter the container later, run: distrobox enter ${CONTAINER_NAME}"
    ;;
esac

echo
