#!/bin/bash
# Validation script to check dependency files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔍 Validating dependency files..."

# Check that all required files exist
required_files=("build.txt" "removable.txt" "required.txt" "runtime.txt")
for file in "${required_files[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

# Load dependencies and check they're not empty
source "$SCRIPT_DIR/load.sh"

echo "📋 Loaded dependencies:"
echo "  BUILD_DEPS: $(echo $BUILD_DEPS | wc -w) packages"
echo "  DEV_LIBS_REMOVABLE: $(echo $DEV_LIBS_REMOVABLE | wc -w) packages"
echo "  DEV_LIBS_REQUIRED: $(echo $DEV_LIBS_REQUIRED | wc -w) packages"
echo "  RUNTIME_DEPS: $(echo $RUNTIME_DEPS | wc -w) packages"

# Check for duplicates across categories
all_deps="$BUILD_DEPS $DEV_LIBS_REMOVABLE $DEV_LIBS_REQUIRED $RUNTIME_DEPS"
unique_count=$(echo $all_deps | tr ' ' '\n' | sort -u | wc -l)
total_count=$(echo $all_deps | wc -w)

if [[ $unique_count -ne $total_count ]]; then
    echo "⚠️  Warning: Found duplicate dependencies across categories"
    echo "   Total: $total_count, Unique: $unique_count"
    echo "   Duplicates:"
    echo $all_deps | tr ' ' '\n' | sort | uniq -d
else
    echo "✅ No duplicate dependencies found"
fi

echo "✅ All dependency files are valid!"
