#!/bin/bash
# Environment verification script for R development environment container
# This script checks all components that remain after the cleanup process
# Usage: ./env-verify.sh [startup|push]

SCRIPT_NAME="R Environment Verification"
LOG_DIR="/project/logs"
LOG_FILE="$LOG_DIR/verification.log"
SUMMARY_FILE="$LOG_DIR/verification_summary.log"

# Post-verification action parameter
POST_ACTION="$1"

# Configuration (should match docker-build.sh)
IMAGE_NAME="my-r-env"
CONTAINER_NAME="r-dev"
RENV_CACHE_HOST="$HOME/.cache/R/renv"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "INFO")
            echo -e "${BLUE}[$level]${NC} $message"
            ;;
        "PASS")
            echo -e "${GREEN}[$level]${NC} $message"
            ;;
        "FAIL")
            echo -e "${RED}[$level]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[$level]${NC} $message"
            ;;
        *)
            echo "[$level] $message"
            ;;
    esac
}

check_command() {
    local description="$1"
    shift
    local command="$*"
    
    ((TOTAL_CHECKS++))
    
    log_message "INFO" "Checking: $description"
    
    if eval "$command" >/dev/null 2>&1; then
        log_message "PASS" "✓ $description"
        ((PASSED_CHECKS++))
        return 0
    else
        log_message "FAIL" "✗ $description"
        ((FAILED_CHECKS++))
        return 1
    fi
}

check_version() {
    local description="$1"
    shift
    local command="$*"
    
    ((TOTAL_CHECKS++))
    
    log_message "INFO" "Checking version: $description"
    
    local version_output
    version_output=$(eval "$command" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_message "PASS" "✓ $description"
        log_message "INFO" "  Version: $version_output"
        ((PASSED_CHECKS++))
        return 0
    else
        log_message "FAIL" "✗ $description"
        log_message "FAIL" "  Error: $version_output"
        ((FAILED_CHECKS++))
        return 1
    fi
}

check_file_exists() {
    local description="$1"
    local filepath="$2"
    
    ((TOTAL_CHECKS++))
    
    log_message "INFO" "Checking file exists: $description"
    
    if [ -f "$filepath" ]; then
        log_message "PASS" "✓ $description ($filepath)"
        ((PASSED_CHECKS++))
        return 0
    else
        log_message "FAIL" "✗ $description ($filepath not found)"
        ((FAILED_CHECKS++))
        return 1
    fi
}

check_r_functionality() {
    log_message "INFO" "Testing R functionality..."
    
    local r_test_script='/tmp/test_r.R'
    cat > "$r_test_script" << 'EOF'
cat("R is working!\n")
library(renv)
cat("renv version:", as.character(packageVersion("renv")), "\n")
status <- renv::status()
cat("renv status completed\n")
EOF
    
    ((TOTAL_CHECKS++))
    
    if R --vanilla -e "source('$r_test_script')" >/dev/null 2>&1; then
        log_message "PASS" "✓ R functionality test"
        ((PASSED_CHECKS++))
    else
        log_message "FAIL" "✗ R functionality test"
        ((FAILED_CHECKS++))
    fi
    
    rm -f "$r_test_script"
}

check_latex_functionality() {
    log_message "INFO" "Testing LaTeX functionality..."
    
    local latex_test_file='/tmp/test.tex'
    cat > "$latex_test_file" << 'EOF'
\documentclass{article}
\begin{document}
Hello LaTeX!
\end{document}
EOF
    
    ((TOTAL_CHECKS++))
    
    if pdflatex -interaction=nonstopmode -output-directory=/tmp "$latex_test_file" >/dev/null 2>&1; then
        log_message "PASS" "✓ LaTeX functionality test"
        ((PASSED_CHECKS++))
    else
        log_message "FAIL" "✗ LaTeX functionality test"
        ((FAILED_CHECKS++))
    fi
    
    rm -f /tmp/test.*
}

check_python_packages() {
    log_message "INFO" "Checking Python packages..."
    
    ((TOTAL_CHECKS++))
    
    if python3 -c "import radian; print('radian imported successfully')" >/dev/null 2>&1; then
        log_message "PASS" "✓ Python radian package"
        ((PASSED_CHECKS++))
    else
        log_message "FAIL" "✗ Python radian package"
        ((FAILED_CHECKS++))
    fi
}

generate_summary() {
    log_message "INFO" "Generating summary..."
    
    cat > "$SUMMARY_FILE" << EOF
=== $SCRIPT_NAME Summary ===
Timestamp: $(date)
Total checks: $TOTAL_CHECKS
Passed: $PASSED_CHECKS
Failed: $FAILED_CHECKS

EOF
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo "Overall status: ALL CHECKS PASSED ✓" >> "$SUMMARY_FILE"
        log_message "PASS" "All verification checks passed!"
    else
        echo "Overall status: $FAILED_CHECKS CHECK(S) FAILED ✗" >> "$SUMMARY_FILE"
        log_message "FAIL" "$FAILED_CHECKS verification check(s) failed!"
    fi
     cat >> "$SUMMARY_FILE" << EOF

Detailed log: $LOG_FILE
EOF

    # Display summary
    echo ""
    echo "=== VERIFICATION SUMMARY ==="
    cat "$SUMMARY_FILE"
}

handle_post_verification_action() {
    if [ $FAILED_CHECKS -ne 0 ]; then
        log_message "FAIL" "Skipping post-verification action due to failed checks"
        return 1
    fi
    
    case "$POST_ACTION" in
        "startup")
            log_message "INFO" "Post-verification action: Starting container..."
            echo ""
            echo "🚀 Starting interactive R development container..."
            ./docker-run-local.sh
            ;;
        "push")
            log_message "INFO" "Post-verification action: Pushing to Docker Hub then starting container..."
            echo ""
            echo "📤 Pushing image to Docker Hub..."
            ./docker-push.sh
            if [ $? -eq 0 ]; then
                echo ""
                echo "🚀 Starting interactive R development container..."
                ./docker-run-local.sh
            else
                log_message "FAIL" "Docker Hub push failed, skipping container startup"
                return 1
            fi
            ;;
        "")
            log_message "INFO" "No post-verification action specified"
            ;;
        *)
            log_message "WARN" "Unknown post-verification action: $POST_ACTION"
            ;;
    esac
}

main() {
    echo "Starting $SCRIPT_NAME..."
    
    # Show post-verification action if specified
    if [ -n "$POST_ACTION" ]; then
        log_message "INFO" "Post-verification action: $POST_ACTION"
    fi
    
    # Create log directory
    mkdir -p "$LOG_DIR"
    
    # Initialize log file with session timestamp
    cat > "$LOG_FILE" << EOF
=== $SCRIPT_NAME Log ===
Started at: $(date)
Session ID: $(date '+%Y%m%d_%H%M%S')

EOF
    
    log_message "INFO" "Starting verification process..."
    
    # 1. Check Ubuntu base system
    log_message "INFO" "=== Checking Ubuntu Base System ==="
    check_version "Ubuntu version" "lsb_release -d | cut -f2"
    
    # 2. Check R installation
    log_message "INFO" "=== Checking R Installation ==="
    check_version "R version" "R --version | head -1"
    check_command "R base installation" "which R"
    check_command "Rscript availability" "which Rscript"
    check_r_functionality
    
    # 3. Check Fish shell
    log_message "INFO" "=== Checking Fish Shell ==="
    check_version "Fish version" "fish --version"
    check_command "Fish shell availability" "which fish"
    check_file_exists "Fish config file" "/root/.config/fish/config.fish"
    
    # 4. Check Python and radian
    log_message "INFO" "=== Checking Python Environment ==="
    check_version "Python version" "python3 --version"
    check_command "Python3 availability" "which python3"
    check_command "pip3 availability" "which pip3"
    check_command "radian availability" "which radian"
    check_python_packages
    
    # 5. Check Starship prompt
    log_message "INFO" "=== Checking Starship Prompt ==="
    check_version "Starship version" "starship --version"
    check_command "Starship availability" "which starship"
    check_file_exists "Starship config file" "/root/.config/starship.toml"
    
    # 6. Check LaTeX installation
    log_message "INFO" "=== Checking LaTeX Installation ==="
    check_version "pdflatex version" "pdflatex --version | head -1"
    check_command "pdflatex availability" "which pdflatex"
    check_command "latexmk availability" "which latexmk"
    check_latex_functionality
    
    # 7. Check renv and R packages
    log_message "INFO" "=== Checking renv and R Packages ==="
    check_file_exists "renv.lock file" "/project/renv.lock"
    check_file_exists ".Rprofile file" "/project/.Rprofile"
    check_file_exists "renv activate.R" "/project/renv/activate.R"
    check_file_exists "renv settings.json" "/project/renv/settings.json"
    
    # 8. Check that build dependencies were removed
    log_message "INFO" "=== Checking Cleanup ==="
    check_command "/tmp/deps directory removed" "test ! -d /tmp/deps"
    
    # Generate final summary
    generate_summary
    
    log_message "INFO" "Verification completed at: $(date)"
    
    # Handle post-verification actions if verification passed
    if [ $FAILED_CHECKS -eq 0 ]; then
        if [ -n "$POST_ACTION" ]; then
            echo ""
            log_message "INFO" "=== Post-Verification Action ==="
            handle_post_verification_action
            return $?
        else
            return 0
        fi
    else
        return 1
    fi
}

# Run main function
main "$@"
