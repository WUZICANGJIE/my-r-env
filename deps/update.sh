#!/bin/bash
# Script to update Containerfile with latest dependency definitions
# Run this after modifying any dependency files in deps/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINERFILE="$SCRIPT_DIR/../Containerfile"
TEMP_FILE=$(mktemp)

echo "🔄 Updating Containerfile with latest dependency definitions..."

# Generate the new ARG definitions
NEW_ARGS=$("$SCRIPT_DIR/gen-args.sh")

# Create a temporary file with the updated Containerfile
{
    # Copy everything up to the dependency definitions
    sed -n '1,/^ENV RENV_PATHS_CACHE=/p' "$CONTAINERFILE"
    
    # Add the new dependency definitions
    echo ""
    echo "$NEW_ARGS"
    
    # Copy everything after the old dependency definitions
    sed -n '/^# --- 1\. Configure Package Caching/,$p' "$CONTAINERFILE"
} > "$TEMP_FILE"

# Replace the original file
mv "$TEMP_FILE" "$CONTAINERFILE"

echo "✅ Containerfile updated successfully!"
echo "💡 Review the changes and rebuild your container if needed."
