#!/bin/bash
# Docker-specific dependency loader
# This script runs inside the container during build

set -euo pipefail

# Function to load dependencies from a file (removes comments and empty lines)
load_deps() {
    local file="$1"
    if [[ -f "$file" ]]; then
        grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' ' | sed 's/ *$//'
    else
        echo "Error: Dependency file $file not found" >&2
        exit 1
    fi
}

# Load all dependency categories
export BUILD_DEPS=$(load_deps "/tmp/deps/build.txt")
export DEV_LIBS_REMOVABLE=$(load_deps "/tmp/deps/removable.txt")
export DEV_LIBS_REQUIRED=$(load_deps "/tmp/deps/required.txt")
export RUNTIME_DEPS=$(load_deps "/tmp/deps/runtime.txt")

echo "Loaded dependencies:"
echo "  BUILD_DEPS: $BUILD_DEPS"
echo "  DEV_LIBS_REMOVABLE: $DEV_LIBS_REMOVABLE"
echo "  DEV_LIBS_REQUIRED: $DEV_LIBS_REQUIRED"
echo "  RUNTIME_DEPS: $RUNTIME_DEPS"
