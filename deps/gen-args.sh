#!/bin/bash
# Helper script to generate dependency lists for Containerfile
# This script outputs the dependencies in a format suitable for ARG definitions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to format dependencies for Dockerfile ARG (with backslashes)
format_deps() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Read non-comment, non-empty lines and join with space and backslash
        local deps=$(grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' ' | sed 's/ *$//')
        # Split into multiple lines with backslashes for better readability
        echo "$deps" | sed 's/ / \\\n    /g'
    fi
}

echo "# Generated dependency definitions - DO NOT EDIT MANUALLY"
echo "# To update dependencies, modify files in deps/ folder"
echo ""

echo "# Build-time dependencies (can be removed after R installation)"
echo "ARG BUILD_DEPS=\"$(format_deps "$SCRIPT_DIR/build.txt")\""
echo ""

echo "# Development libraries that can be removed (R doesn't directly depend on most of these)"
echo "ARG REMOVABLE_DEV_LIBS=\"$(format_deps "$SCRIPT_DIR/removable.txt")\""
echo ""

echo "# Development libraries that R actually needs (keep these)"
echo "ARG REQUIRED_DEV_LIBS=\"$(format_deps "$SCRIPT_DIR/required.txt")\""
echo ""

echo "# Runtime dependencies"
echo "ARG RUNTIME_DEPS=\"$(format_deps "$SCRIPT_DIR/runtime.txt")\""
