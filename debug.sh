#!/bin/bash
# Debug script to identify which dependencies are actually needed by R

# Load centralized dependency definitions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/deps/load.sh"

echo "=== Checking R dependencies ==="
echo "R base packages depend on:"
apt-cache depends r-base r-base-dev | grep -E "Depends:|Recommends:" | sort | uniq

echo ""
echo "=== Testing BUILD_DEPS removal (should be safe) ==="
echo "What would be removed with BUILD_DEPS:"
apt-get --dry-run purge --auto-remove $BUILD_DEPS 2>/dev/null | grep -E "^Remv" | grep -E "(r-base|r-)"

echo ""
echo "=== Testing DEV_LIBS_REMOVABLE removal (should be safe) ==="
echo "What would be removed with DEV_LIBS_REMOVABLE:"
apt-get --dry-run purge --auto-remove $DEV_LIBS_REMOVABLE 2>/dev/null | grep -E "^Remv" | grep -E "(r-base|r-)"

echo ""
echo "=== Testing DEV_LIBS_REQUIRED removal (might affect R) ==="
echo "What would be removed with DEV_LIBS_REQUIRED:"
apt-get --dry-run purge --auto-remove $DEV_LIBS_REQUIRED 2>/dev/null | grep -E "^Remv" | grep -E "(r-base|r-)"

echo ""
echo "=== Checking which packages depend on each DEV_LIB_REMOVABLE ==="
for pkg in $DEV_LIBS_REMOVABLE; do
    echo "--- Packages depending on $pkg ---"
    apt-cache rdepends $pkg 2>/dev/null | grep -v "Reverse Depends:" | grep -E "(r-|Reverse)" | head -3
done

echo ""
echo "=== Checking which packages depend on each DEV_LIB_REQUIRED ==="
for pkg in $DEV_LIBS_REQUIRED; do
    echo "--- Packages depending on $pkg ---"
    apt-cache rdepends $pkg 2>/dev/null | grep -v "Reverse Depends:" | grep -E "(r-|Reverse)" | head -3
done

echo ""
echo "=== Final test: what happens if we remove everything? ==="
apt-get --dry-run purge --auto-remove $BUILD_DEPS $DEV_LIBS_REMOVABLE 2>/dev/null | grep -E "^Remv.*r-"
