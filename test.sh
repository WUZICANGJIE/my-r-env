#!/bin/bash
# Cross-platform setup and validation script for R development environment
# Compatible with: Debian, Arch, Fedora, macOS, WSL

set -e

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Emojis for better UX (fallback for systems without emoji support)
readonly CHECK_MARK="✅"
readonly CROSS_MARK="❌"
readonly INFO_MARK="ℹ️"
readonly ROCKET="🚀"
readonly DOCKER_ICON="🐳"
readonly WARNING="⚠️"

# Global variables
DETECTED_OS=""
DETECTED_DISTRO=""
IS_WSL=false
DOCKER_COMMAND="docker"

# Function to print colored output
print_status() {
    local level="$1"
    local message="$2"
    case "$level" in
        "success") echo -e "${GREEN}${CHECK_MARK} ${message}${NC}" ;;
        "error") echo -e "${RED}${CROSS_MARK} ${message}${NC}" ;;
        "warning") echo -e "${YELLOW}${WARNING} ${message}${NC}" ;;
        "info") echo -e "${BLUE}${INFO_MARK} ${message}${NC}" ;;
        "header") echo -e "${BLUE}${ROCKET} ${message}${NC}" ;;
    esac
}

# Function to detect operating system and distribution
detect_os() {
    print_status "info" "Detecting operating system..."
    
    # Check for WSL
    if grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
        IS_WSL=true
        print_status "info" "Running on Windows Subsystem for Linux (WSL)"
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        DETECTED_OS="macos"
        print_status "success" "Detected: macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        DETECTED_OS="linux"
        
        # Detect Linux distribution
        if command -v lsb_release >/dev/null 2>&1; then
            DETECTED_DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        elif [[ -f /etc/os-release ]]; then
            DETECTED_DISTRO=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        elif [[ -f /etc/debian_version ]]; then
            DETECTED_DISTRO="debian"
        elif [[ -f /etc/redhat-release ]]; then
            DETECTED_DISTRO="fedora"
        elif [[ -f /etc/arch-release ]]; then
            DETECTED_DISTRO="arch"
        else
            DETECTED_DISTRO="unknown"
        fi
        
        print_status "success" "Detected: Linux ($DETECTED_DISTRO)"
        
        if [[ "$IS_WSL" == true ]]; then
            print_status "info" "WSL environment detected"
        fi
    else
        print_status "error" "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Docker installation
check_docker() {
    print_status "info" "Checking Docker installation..."
    
    # First check if docker command exists in PATH
    if command_exists docker; then
        print_status "success" "Docker is installed"
        
        # Check Docker version
        local docker_version
        docker_version=$(docker --version 2>/dev/null || echo "unknown")
        print_status "info" "Docker version: $docker_version"
        
        return 0
    elif [[ "$IS_WSL" == true ]]; then
        # Check for Docker Desktop on Windows (WSL integration)
        print_status "info" "Checking for Docker Desktop on Windows..."
        
        # Check common Windows Docker Desktop paths
        local windows_docker_paths=(
            "/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe"
            "/mnt/c/Users/$USER/AppData/Local/Docker/Docker/resources/bin/docker.exe"
            "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe"
        )
        
        for docker_path in "${windows_docker_paths[@]}"; do
            if [[ -f "$docker_path" ]]; then
                print_status "success" "Found Docker Desktop on Windows at: $docker_path"
                return 0
            fi
        done
        
        # Check if Docker Desktop WSL integration is enabled
        if [[ -S "/var/run/docker.sock" ]] || [[ -S "$HOME/.docker/run/docker.sock" ]]; then
            print_status "success" "Docker Desktop WSL integration detected"
            return 0
        fi
        
        # Check for docker.exe in Windows PATH
        if command_exists docker.exe; then
            print_status "success" "Docker Desktop found via docker.exe"
            DOCKER_COMMAND="docker.exe"
            return 0
        fi
        
        print_status "error" "Docker Desktop not found or WSL integration not enabled"
        return 1
    else
        print_status "error" "Docker is not installed"
        return 1
    fi
}

# Function to check Docker daemon status
check_docker_daemon() {
    print_status "info" "Checking Docker daemon status..."
    
    # First try standard docker info
    if $DOCKER_COMMAND info >/dev/null 2>&1; then
        print_status "success" "Docker daemon is running"
        return 0
    fi
    
    # If in WSL, check Docker Desktop specific scenarios
    if [[ "$IS_WSL" == true ]]; then
        print_status "info" "WSL detected, checking Docker Desktop status..."
        
        # Check if Docker Desktop is running on Windows
        if command_exists powershell.exe; then
            local docker_desktop_running
            docker_desktop_running=$(powershell.exe -Command "Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count" 2>/dev/null || echo "0")
            
            if [[ "$docker_desktop_running" -gt 0 ]]; then
                print_status "info" "Docker Desktop is running on Windows"
                
                # Wait a moment for Docker to be fully ready
                print_status "info" "Waiting for Docker Desktop to be ready..."
                for i in {1..30}; do
                    if $DOCKER_COMMAND info >/dev/null 2>&1; then
                        print_status "success" "Docker daemon is now accessible"
                        return 0
                    fi
                    sleep 1
                done
                
                print_status "warning" "Docker Desktop is running but daemon is not accessible from WSL"
            else
                print_status "warning" "Docker Desktop is not running on Windows"
            fi
        fi
        
        # Check for docker socket files
        if [[ -S "/var/run/docker.sock" ]]; then
            print_status "info" "Found Docker socket at /var/run/docker.sock"
            if $DOCKER_COMMAND info >/dev/null 2>&1; then
                print_status "success" "Docker daemon is accessible via socket"
                return 0
            fi
        fi
        
        if [[ -S "$HOME/.docker/run/docker.sock" ]]; then
            print_status "info" "Found Docker socket at $HOME/.docker/run/docker.sock"
            export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"
            if $DOCKER_COMMAND info >/dev/null 2>&1; then
                print_status "success" "Docker daemon is accessible via user socket"
                return 0
            fi
        fi
    fi
    
    print_status "error" "Docker daemon is not running"
    return 1
}

# Function to handle Docker daemon not running
handle_docker_daemon_not_running() {
    echo
    print_status "warning" "Docker is installed but the daemon is not running"
    echo
    
    if [[ "$IS_WSL" == true ]]; then
        print_status "info" "WSL detected. Docker daemon issues can be caused by:"
        echo "  1. Docker Desktop is not started on Windows"
        echo "  2. Docker Desktop WSL integration is not enabled"
        echo "  3. Docker service is not running in WSL"
        echo
        
        # Check if Docker Desktop is installed on Windows
        local docker_desktop_found=false
        if [[ -f "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe" ]]; then
            docker_desktop_found=true
            print_status "info" "Docker Desktop found at: /mnt/c/Program Files/Docker/Docker/Docker Desktop.exe"
        fi
        
        if [[ "$docker_desktop_found" == true ]]; then
            print_status "info" "To fix Docker Desktop issues:"
            echo "  1. Start Docker Desktop on Windows:"
            echo "     • Open Docker Desktop from Windows Start Menu"
            echo "     • Or run: powershell.exe -Command \"Start-Process 'C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe'\""
            echo "  2. Enable WSL integration in Docker Desktop:"
            echo "     • Settings → Resources → WSL Integration"
            echo "     • Enable integration for your WSL distribution"
            echo "  3. Wait for Docker Desktop to fully start (usually 10-20 seconds)"
            echo
            
            echo "Would you like to try starting Docker Desktop from Windows? (y/N)"
            read -r response
            
            if [[ "$response" =~ ^[Yy]$ ]]; then
                print_status "info" "Attempting to start Docker Desktop on Windows..."
                if powershell.exe -Command "Start-Process 'C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe'" 2>/dev/null; then
                    print_status "info" "Docker Desktop start command sent. Please wait for it to fully start..."
                    
                    # Wait for Docker Desktop to start
                    print_status "info" "Waiting up to 60 seconds for Docker Desktop to be ready..."
                    for i in {1..60}; do
                        if $DOCKER_COMMAND info >/dev/null 2>&1; then
                            print_status "success" "Docker Desktop is now ready!"
                            return 0
                        fi
                        if [[ $((i % 5)) -eq 0 ]]; then
                            echo -n "."
                        fi
                        sleep 1
                    done
                    echo
                    print_status "warning" "Docker Desktop may still be starting. Please wait a bit more and try again."
                    return 1
                else
                    print_status "error" "Failed to start Docker Desktop. Please start it manually from Windows."
                    return 1
                fi
            else
                print_status "info" "Please start Docker Desktop manually on Windows and ensure WSL integration is enabled."
                return 1
            fi
        else
            print_status "info" "Docker Desktop not found in standard location. Alternative solutions:"
            echo "  • Install Docker directly in WSL: sudo systemctl start docker"
            echo "  • Or ensure Docker Desktop is properly installed on Windows"
            echo
            echo "Would you like to try starting the Docker service in WSL? (y/N)"
            read -r response
            
            if [[ "$response" =~ ^[Yy]$ ]]; then
                print_status "info" "Attempting to start Docker service in WSL..."
                if sudo systemctl start docker 2>/dev/null; then
                    print_status "success" "Docker service started successfully in WSL"
                    return 0
                else
                    print_status "error" "Failed to start Docker service in WSL. Please install Docker in WSL or use Docker Desktop."
                    return 1
                fi
            else
                print_status "info" "Please start Docker Desktop on Windows or install Docker in WSL."
                return 1
            fi
        fi
    else
        print_status "info" "Please start the Docker daemon:"
        case "$DETECTED_DISTRO" in
            "ubuntu"|"debian"|"arch"|"manjaro"|"fedora"|"centos"|"rhel")
                echo "  sudo systemctl start docker"
                echo "  sudo systemctl enable docker  # (to start on boot)"
                ;;
            *)
                echo "  Please refer to your system's documentation for starting Docker"
                ;;
        esac
        echo
        echo "Would you like to try starting Docker now? (y/N)"
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_status "info" "Attempting to start Docker service..."
            if sudo systemctl start docker 2>/dev/null; then
                print_status "success" "Docker service started successfully"
                # Give Docker a moment to fully start
                sleep 2
                return 0
            else
                print_status "error" "Failed to start Docker service. Please start it manually."
                return 1
            fi
        else
            print_status "info" "Please start Docker manually and rerun this script."
            return 1
        fi
    fi
}

# Function to install Docker on different systems
install_docker() {
    local install_docker=false
    
    echo
    print_status "warning" "Docker is not installed"
    echo
    echo "Would you like to install Docker? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        install_docker=true
    fi
    
    if [[ "$install_docker" == false ]]; then
        print_status "info" "Skipping Docker installation. Please install Docker manually and rerun this script."
        return 1
    fi
    
    print_status "info" "Installing Docker for $DETECTED_OS ($DETECTED_DISTRO)..."
    
    case "$DETECTED_OS" in
        "macos")
            print_status "info" "Please download and install Docker Desktop from: https://www.docker.com/products/docker-desktop"
            print_status "info" "Or install via Homebrew: brew install --cask docker"
            ;;
        "linux")
            case "$DETECTED_DISTRO" in
                "ubuntu"|"debian")
                    print_status "info" "Installing Docker on Debian/Ubuntu..."
                    sudo apt-get update
                    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                    curl -fsSL https://download.docker.com/linux/$DETECTED_DISTRO/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DETECTED_DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                    sudo apt-get update
                    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                    ;;
                "arch"|"manjaro")
                    print_status "info" "Installing Docker on Arch Linux..."
                    sudo pacman -S --noconfirm docker docker-buildx docker-compose
                    ;;
                "fedora"|"centos"|"rhel")
                    print_status "info" "Installing Docker on Fedora/RHEL..."
                    sudo dnf -y install dnf-plugins-core
                    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                    ;;
                *)
                    print_status "error" "Automatic Docker installation not supported for $DETECTED_DISTRO"
                    print_status "info" "Please install Docker manually: https://docs.docker.com/engine/install/"
                    return 1
                    ;;
            esac
            
            # Start and enable Docker service
            if [[ "$IS_WSL" == false ]]; then
                print_status "info" "Starting Docker service..."
                sudo systemctl start docker
                sudo systemctl enable docker
                
                # Add user to docker group
                print_status "info" "Adding user to docker group..."
                sudo usermod -aG docker "$USER"
                print_status "warning" "Please log out and log back in for group changes to take effect"
            else
                print_status "info" "WSL detected. Please ensure Docker Desktop is running on Windows"
            fi
            ;;
    esac
}

# Function to check Docker BuildKit support
check_buildkit() {
    print_status "info" "Checking Docker BuildKit support..."
    
    if $DOCKER_COMMAND buildx version >/dev/null 2>&1; then
        print_status "success" "Docker BuildKit is available"
        export DOCKER_BUILDKIT=1
        return 0
    else
        print_status "warning" "Docker BuildKit not available, builds may be slower"
        return 1
    fi
}

# Function to validate project files
validate_project_files() {
    print_status "info" "Validating project files..."
    
    # Check main scripts
    local scripts=("build.sh" "local.sh" "hub.sh" "debug.sh")
    for script in "${scripts[@]}"; do
        if [[ -x "$script" ]]; then
            print_status "success" "$script: EXISTS and EXECUTABLE"
        else
            print_status "error" "$script: MISSING or NOT EXECUTABLE"
            return 1
        fi
    done
    
    # Check essential files
    local files=("Containerfile" "renv.lock" ".Rprofile")
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "success" "$file: EXISTS"
        else
            print_status "error" "$file: MISSING"
            return 1
        fi
    done
    
    # Check dependency files
    local dep_files=("deps/build.txt" "deps/removable.txt" "deps/required.txt" "deps/runtime.txt")
    for file in "${dep_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "success" "$file: EXISTS"
        else
            print_status "error" "$file: MISSING"
            return 1
        fi
    done
    
    return 0
}

# Function to validate dependencies
validate_dependencies() {
    print_status "info" "Validating dependencies..."
    
    if [[ -x "deps/validate.sh" ]]; then
        if ./deps/validate.sh | grep -q "✅ All dependency files are valid!"; then
            print_status "success" "Dependency validation: PASSED"
            return 0
        else
            print_status "error" "Dependency validation: FAILED"
            return 1
        fi
    else
        print_status "error" "deps/validate.sh: MISSING or NOT EXECUTABLE"
        return 1
    fi
}

# Function to test dependency loading
test_dependency_loading() {
    print_status "info" "Testing dependency loading..."
    
    if [[ -f "deps/load.sh" ]]; then
        # shellcheck source=/dev/null
        source deps/load.sh
        
        if [[ -n "$BUILD_DEPS" && -n "$DEV_LIBS_REMOVABLE" && -n "$DEV_LIBS_REQUIRED" && -n "$RUNTIME_DEPS" ]]; then
            print_status "success" "Dependency loading: PASSED"
            return 0
        else
            print_status "error" "Dependency loading: FAILED - Some variables are empty"
            return 1
        fi
    else
        print_status "error" "deps/load.sh: MISSING"
        return 1
    fi
}

# Function to check disk space
check_disk_space() {
    print_status "info" "Checking available disk space..."
    
    local available_space
    if command_exists df; then
        available_space=$(df -h . | awk 'NR==2 {print $4}')
        print_status "info" "Available disk space: $available_space"
        
        # Convert to bytes for comparison (rough estimate)
        local space_gb
        space_gb=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
        
        if [[ "$space_gb" -lt 5 ]]; then
            print_status "warning" "Low disk space detected. Docker builds may fail with less than 5GB available"
        else
            print_status "success" "Sufficient disk space available"
        fi
    else
        print_status "warning" "Cannot check disk space - df command not available"
    fi
}

# Function to check system requirements
check_system_requirements() {
    print_status "info" "Checking system requirements..."
    
    # Check memory
    if [[ "$DETECTED_OS" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
        local mem_gb
        mem_gb=$(free -g | awk 'NR==2{print $2}')
        if [[ "$mem_gb" -lt 4 ]]; then
            print_status "warning" "System has less than 4GB RAM. Docker builds may be slow"
        else
            print_status "success" "Sufficient RAM available ($mem_gb GB)"
        fi
    fi
    
    # Check if we're in the right directory
    if [[ ! -f "Containerfile" ]]; then
        print_status "error" "Not in the correct directory. Please run this script from the project root"
        return 1
    fi
    
    return 0
}

# Function to prompt for build
prompt_build() {
    echo
    print_status "header" "Setup validation complete!"
    echo
    echo "All checks passed! Your system is ready to build the R development environment."
    echo
    echo "${DOCKER_ICON} Would you like to run the build script now? (Y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Nn]$ ]]; then
        print_status "info" "Skipping build. You can run './build.sh' manually when ready."
        return 0
    fi
    
    print_status "info" "Starting build process..."
    if [[ -x "./build.sh" ]]; then
        ./build.sh
    else
        print_status "error" "build.sh is not executable"
        return 1
    fi
}

# Function to show help
show_help() {
    echo "R Development Environment Setup Script"
    echo
    echo "This script validates your system and prepares it for building the R development container."
    echo
    echo "Supported platforms:"
    echo "  - Debian/Ubuntu Linux"
    echo "  - Arch Linux"
    echo "  - Fedora/RHEL/CentOS"
    echo "  - macOS"
    echo "  - Windows Subsystem for Linux (WSL)"
    echo
    echo "Usage:"
    echo "  $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --skip-docker  Skip Docker installation/setup"
    echo "  --no-build     Don't prompt to run build.sh"
    echo
    echo "What this script does:"
    echo "  1. Detects your operating system and distribution"
    echo "  2. Checks Docker installation and status"
    echo "  3. Offers to install Docker if missing"
    echo "  4. Helps start Docker daemon if not running (common in WSL)"
    echo "  5. Validates all project files and dependencies"
    echo "  6. Checks system requirements"
    echo "  7. Prompts to run the build script"
}

# Main function
main() {
    local skip_docker=false
    local no_build=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --skip-docker)
                skip_docker=true
                shift
                ;;
            --no-build)
                no_build=true
                shift
                ;;
            *)
                print_status "error" "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    echo
    print_status "header" "R Development Environment Setup"
    echo
    
    # Step 1: Detect OS
    detect_os
    echo
    
    # Step 2: Check system requirements
    if ! check_system_requirements; then
        exit 1
    fi
    echo
    
    # Step 3: Check disk space
    check_disk_space
    echo
    
    # Step 4: Docker setup
    if [[ "$skip_docker" == false ]]; then
        local docker_installed=false
        local docker_daemon_running=false
        
        # Check if Docker is installed
        if check_docker; then
            docker_installed=true
            
            # Check if Docker daemon is running
            if check_docker_daemon; then
                docker_daemon_running=true
            fi
        fi
        
        # Handle different Docker states
        if [[ "$docker_installed" == false ]]; then
            # Docker not installed - offer to install
            if ! install_docker; then
                print_status "error" "Docker installation failed or was skipped. Please install Docker manually and rerun this script."
                exit 1
            fi
            
            # Re-check after installation
            if ! check_docker; then
                print_status "error" "Docker installation verification failed."
                exit 1
            fi
            
            # Check daemon after installation
            if ! check_docker_daemon; then
                print_status "error" "Docker daemon is not running after installation. Please start Docker and try again."
                exit 1
            fi
            
        elif [[ "$docker_installed" == true && "$docker_daemon_running" == false ]]; then
            # Docker installed but daemon not running - offer to start
            if ! handle_docker_daemon_not_running; then
                print_status "error" "Docker daemon setup failed. Please start Docker manually and rerun this script."
                exit 1
            fi
            
            # Verify daemon is now running
            if ! check_docker_daemon; then
                print_status "error" "Docker daemon is still not running. Please check Docker status and try again."
                exit 1
            fi
        fi
        
        # At this point, Docker should be installed and running
        print_status "success" "Docker is ready!"
        
        # Check BuildKit
        check_buildkit
        echo
    else
        print_status "info" "Skipping Docker checks (--skip-docker flag used)"
        echo
    fi
    
    # Step 5: Validate project files
    if ! validate_project_files; then
        print_status "error" "Project validation failed. Please ensure all required files are present."
        exit 1
    fi
    echo
    
    # Step 6: Validate dependencies
    if ! validate_dependencies; then
        print_status "error" "Dependency validation failed. Please check your dependency files."
        exit 1
    fi
    echo
    
    # Step 7: Test dependency loading
    if ! test_dependency_loading; then
        print_status "error" "Dependency loading test failed."
        exit 1
    fi
    echo
    
    # Step 8: Prompt for build
    if [[ "$no_build" == false ]]; then
        prompt_build
    else
        print_status "info" "Setup complete! Run './build.sh' when ready to build the container."
    fi
    
    echo
    print_status "success" "Setup script completed successfully!"
    echo
    echo "📚 Quick reference:"
    echo "  ./build.sh     - Build the container"
    echo "  ./local.sh     - Run locally built container"
    echo "  ./hub.sh       - Run from Docker Hub"
    echo "  ./debug.sh     - Debug dependencies"
    echo "  ./deps/        - Manage dependencies"
    echo
}

# Run main function with all arguments
main "$@"
