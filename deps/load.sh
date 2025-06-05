#!/bin/bash
# Helper script to load dependency lists
# Usage: source deps/load-deps.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to load dependencies from a file (removes comments and empty lines)
load_deps() {
    local file="$1"
    if [[ -f "$file" ]]; then
        grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' '
    else
        echo "Warning: Dependency file $file not found" >&2
    fi
}

# Load all dependency categories
BUILD_DEPS=$(load_deps "$SCRIPT_DIR/build.txt")
DEV_LIBS_REMOVABLE=$(load_deps "$SCRIPT_DIR/removable.txt")
DEV_LIBS_REQUIRED=$(load_deps "$SCRIPT_DIR/required.txt")
RUNTIME_DEPS=$(load_deps "$SCRIPT_DIR/runtime.txt")

# For backward compatibility with existing scripts
DEV_LIBS="$DEV_LIBS_REMOVABLE $DEV_LIBS_REQUIRED"
BUILD_TOOLS="$BUILD_DEPS"

# Export variables so they can be used by calling scripts
export BUILD_DEPS DEV_LIBS_REMOVABLE DEV_LIBS_REQUIRED RUNTIME_DEPS DEV_LIBS BUILD_TOOLS
