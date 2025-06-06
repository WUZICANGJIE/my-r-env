#!/bin/bash
# Build script for renv-enabled R container

set -e

# Enable BuildKit for faster builds and cache mounts
export DOCKER_BUILDKIT=1

# Configuration
IMAGE_NAME="my-r-env"
CONTAINER_NAME="r-dev"
RENV_CACHE_HOST="$HOME/.cache/R/renv"

# Docker Hub configuration (set your username here)
DOCKERHUB_USERNAME="wuzicangjie"  # Change this to your Docker Hub username
DOCKERHUB_IMAGE_NAME="${DOCKERHUB_USERNAME}/my-r-env"
IMAGE_TAG="latest"
FULL_DOCKERHUB_NAME="${DOCKERHUB_IMAGE_NAME}:${IMAGE_TAG}"

# Create cache directory if it doesn't exist
mkdir -p "$RENV_CACHE_HOST"

echo "Building Docker image with renv..."
echo "BuildKit enabled for faster builds and cache mounts..."

# Build with optimized cache settings
docker build \
    --progress=plain \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    -t "$IMAGE_NAME" \
    -f Containerfile \
    .

echo "Image built successfully!"

# --- Docker Hub Upload Option ---
echo ""
read -p "Do you want to push the image to Docker Hub? (y/N) " -n 1 -r choice
echo ""

if [[ $choice =~ ^[Yy]$ ]]; then
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
    else
        echo ">>> Failed to push image. Please check Docker Hub credentials."
        exit 1
    fi
else
    echo ">>> Skipping Docker Hub push. Using local image only."
fi

echo ""
echo "================================================="
echo ">>> Build complete!"
echo "================================================="

# --- Automated Verification Option ---
echo ""
read -p "Do you want to run verification tests now? (Y/n) " -n 1 -r verify_choice
echo ""

if [[ $verify_choice =~ ^[Nn]$ ]]; then
    echo ">>> Skipping verification. You can run it manually later."
    echo ""
    echo "🚀 Manual verification options:"
    echo ""
    echo "1️⃣  Start the container interactively:"
    echo "    ./local.sh"
    echo ""
    echo "2️⃣  Inside the container, run verification tests:"
    echo "    ./verify.sh"
    echo ""
    echo "📋 Alternative verification methods:"
    echo ""
    echo "• Quick verification in detached container:"
    echo "  docker run --rm \\"
    echo "    -e 'RENV_PATHS_CACHE=/renv/cache' \\"
    echo "    -v '$RENV_CACHE_HOST:/renv/cache' \\"
    echo "    -v '\$(pwd):/project' \\"
    echo "    -w /project \\"
    echo "    $IMAGE_NAME ./verify.sh"
    echo ""
    echo "• Start container in background for exec commands:"
    echo "  docker run -d --name r-dev-temp \\"
    echo "    -e 'RENV_PATHS_CACHE=/renv/cache' \\"
    echo "    -v '$RENV_CACHE_HOST:/renv/cache' \\"
    echo "    -v '\$(pwd):/project' \\"
    echo "    -w /project \\"
    echo "    $IMAGE_NAME tail -f /dev/null"
    echo "  docker exec -it r-dev-temp ./verify.sh"
    echo "  docker stop r-dev-temp && docker rm r-dev-temp"
    echo ""
    echo "💡 The verification script will show actual check counts when complete."
else
    echo ">>> Running comprehensive verification tests..."
    echo ""
    
    # Use the same container setup as local.sh but in detached mode for testing
    VERIFY_CONTAINER="r-dev-verify"
    
    # Remove any existing verification container
    if docker ps -a --format '{{.Names}}' | grep -q "^${VERIFY_CONTAINER}$"; then
        echo "Cleaning up existing verification container..."
        docker rm -f "$VERIFY_CONTAINER" >/dev/null 2>&1
    fi
    
    echo "🔍 Starting verification container..."
    
    # Start container in detached mode (same config as local.sh but without -it --rm)
    docker run -d --name "$VERIFY_CONTAINER" \
        -e "RENV_PATHS_CACHE=/renv/cache" \
        -v "$RENV_CACHE_HOST:/renv/cache" \
        -v "$(pwd):/project" \
        -w /project \
        "$IMAGE_NAME" tail -f /dev/null
    
    echo "🧪 Running verification tests..."
    
    # Run verification inside the container
    if docker exec "$VERIFY_CONTAINER" ./verify.sh; then
        echo ""
        echo "✅ Verification completed successfully!"
        echo ""
        
        # Get actual verification counts from the log
        TOTAL_CHECKS=$(docker exec "$VERIFY_CONTAINER" grep -o "Total checks: [0-9]*" /project/logs/verification_summary.log | grep -o "[0-9]*" 2>/dev/null || echo "unknown")
        PASSED_CHECKS=$(docker exec "$VERIFY_CONTAINER" grep -o "Passed: [0-9]*" /project/logs/verification_summary.log | grep -o "[0-9]*" 2>/dev/null || echo "unknown")
        
        echo "🎉 VERIFICATION SUCCESSFUL!"
        echo "   - All $TOTAL_CHECKS verification checks passed ($PASSED_CHECKS/$TOTAL_CHECKS)"
        echo "   - R environment fully functional"
        echo "   - Container image ready for use"
        
        # Clean up verification container
        docker rm -f "$VERIFY_CONTAINER" >/dev/null 2>&1
        
    else
        echo ""
        echo "❌ Verification failed!"
        echo ""
        echo "🔧 Container '$VERIFY_CONTAINER' preserved for debugging:"
        echo "   Inspect with: docker exec -it $VERIFY_CONTAINER bash"
        echo "   View logs: docker exec $VERIFY_CONTAINER ls -la /project/logs/"
        echo "   Remove when done: docker rm -f $VERIFY_CONTAINER"
        echo ""
        echo "📋 Alternative: Start fresh container with:"
        echo "   ./local.sh  # then run ./verify.sh inside"
        exit 1
    fi
fi

echo ""
echo "Docker Hub image (if pushed): $FULL_DOCKERHUB_NAME"
