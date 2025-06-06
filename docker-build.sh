#!/bin/bash
# Docker build script for renv-enabled R container

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
echo "1) Verify and startup now (default)"
echo "2) Verify and push to Docker Hub"
echo "3) Startup without verification"
echo "4) Show manual options"
echo ""
read -p "Enter your choice (1/2/3/4): " -n 1 -r post_build_choice
echo ""

case $post_build_choice in
    2)
        echo ">>> Running verification tests then pushing to Docker Hub..."
        # Run verification first
        VERIFY_FIRST=true
        ;;
    3)
        echo ">>> Starting container without verification..."
        echo ""
        ./docker-run-local.sh
        exit 0
        ;;
    4)
        echo ">>> Showing manual options..."
        echo ""
        echo "🚀 Manual options:"
        echo ""
        echo "1️⃣  Start the container interactively:"
        echo "    ./local.sh"
        echo ""
        echo "2️⃣  Run verification tests:"
        echo "    ./verify.sh  # (inside container)"
        echo ""
        echo "3️⃣  Upload image to Docker Hub:"
        echo "    ./docker-push.sh"
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
        exit 0
        ;;
    1|*)
        echo ">>> Running verification tests then starting container (default)..."
        # Run verification first
        VERIFY_FIRST=true
        ;;
esac

if [[ "$VERIFY_FIRST" == "true" ]]; then
    echo ">>> Running verification tests..."
    echo ""
    
    # Determine the action after verification
    if [[ $post_build_choice == "2" ]]; then
        # Option 2: Verify and push to Docker Hub
        ./env-verify.sh "push"
    else
        # Option 1 (default): Verify and startup
        ./env-verify.sh "startup"
    fi
    
    # Check exit status of env-verify.sh
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✅ Verification and post-verification action completed successfully!"
    else
        echo ""
        echo "❌ Verification or post-verification action failed!"
        exit 1
    fi
fi

echo ""
echo "================================================="
