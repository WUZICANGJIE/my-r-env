#!/bin/bash
# Filename: deploy.sh
# ===================
#
# This script automates the process of pulling the container image
# from Docker Hub and creating the Distrobox container from it.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Set Docker Hub username and desired image name here.
# Ensure these match the values used in setup.sh
DOCKERHUB_USERNAME="wuzicangjie"
IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# Name for local Distrobox container.
CONTAINER_NAME="r-env"
CONTAINER_HOME_DIR="$HOME/.distrobox-homes/$CONTAINER_NAME"


# --- Main Script ---
echo "================================================="
echo " R Development Environment Deployment"
echo "================================================="
echo "Image to use: ${FULL_IMAGE_NAME}"
echo "Container to create: ${CONTAINER_NAME}"
echo "Container home: ${CONTAINER_HOME_DIR}"
echo "-------------------------------------------------"

# --- Step 1: Pull the image from Docker Hub ---
echo ">>> Pulling image ${FULL_IMAGE_NAME} from Docker Hub..."
podman pull "${FULL_IMAGE_NAME}"

# --- Step 2: Create the Distrobox container ---

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

# --- Step 3: (Optional) Start the container ---
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
