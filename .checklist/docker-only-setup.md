# Docker-Only R Development Environment Setup Checklist

## 🎯 Overview
This checklist covers setting up a containerized R development environment where **only Docker is required on the host system**. All R packages, build tools, and dependencies are managed inside the container.

## ✅ Prerequisites Checklist

### Essential Requirements
- [ ] **Docker Engine** installed and running
- [ ] **Docker BuildX** plugin installed
- [ ] **User added to docker group** (optional, to avoid sudo)
- [ ] **Docker verification** completed successfully

### Docker Installation by OS

#### Ubuntu/Debian
- [ ] Update package index: `sudo apt update`
- [ ] Install Docker: `sudo apt install docker.io docker-buildx-plugin`
- [ ] Enable Docker service: `sudo systemctl enable --now docker`

#### Arch Linux
- [ ] Install Docker: `sudo pacman -S docker docker-buildx`
- [ ] Enable Docker service: `sudo systemctl enable --now docker`

#### Fedora
- [ ] Install Docker: `sudo dnf install docker docker-buildx-plugin`
- [ ] Enable Docker service: `sudo systemctl enable --now docker`

#### macOS
- [ ] Install Docker Desktop: `brew install --cask docker`
- [ ] Start Docker Desktop application

#### Windows
- [ ] Install Docker Desktop: `winget install Docker.DockerDesktop`
- [ ] Restart computer and start Docker Desktop
- [ ] Verify Docker is running in system tray

## 🔧 Configuration Checklist

### Docker Group Setup (Optional)
- [ ] Add user to docker group: `sudo usermod -aG docker $USER`
- [ ] Log out and back in for changes to take effect
- [ ] Test group membership: `groups | grep docker`

## ✅ Verification Checklist

### Docker Installation
- [ ] Check Docker version: `docker --version`
- [ ] Check BuildX version: `docker buildx version`
- [ ] Test Docker functionality: `docker run --rm hello-world`
- [ ] Check Docker service status: `sudo systemctl status docker` (Linux only)

### Windows-Specific Verification
- [ ] Verify Docker Desktop is running (check system tray)
- [ ] Check WSL 2 integration: `wsl -l -v` (should show Running)
- [ ] Test Docker in PowerShell: `docker run --rm hello-world`
- [ ] Verify BuildKit environment variable: `echo $env:DOCKER_BUILDKIT` (PowerShell)
- [ ] Check Docker Desktop settings for resource allocation

### BuildKit Verification
- [ ] Verify BuildKit is enabled: `docker buildx ls`
- [ ] Check current builder: `docker buildx inspect`

## 🚀 Project Setup Checklist

### Initial Setup
- [ ] Clone or navigate to project directory
- [ ] Verify Containerfile exists
- [ ] Verify build scripts exist (`build.sh`, `local.sh`, etc.)
- [ ] Check dependency files in `deps/` directory

### Build Process
- [ ] Run initial build: `./build.sh`
- [ ] Verify successful container creation
- [ ] Test container startup: `./local.sh`
- [ ] Verify R environment loads correctly

## 🔍 Troubleshooting Checklist

### Common Issues
- [ ] **Permission denied**: Ensure user is in docker group or use sudo
- [ ] **BuildKit not found**: Install docker-buildx-plugin
- [ ] **Service not running**: Start Docker service with systemctl
- [ ] **Cache issues**: Clear Docker cache with `docker system prune`

### Windows-Specific Issues
- [ ] **Hyper-V conflicts**: Disable VirtualBox/VMware or use WSL 2 backend
- [ ] **WSL 2 not enabled**: Run `wsl --install` in PowerShell as Admin
- [ ] **Docker Desktop won't start**: 
  - [ ] Check Windows version compatibility (Windows 10 Build 19041+)
  - [ ] Restart Docker Desktop service
  - [ ] Reset Docker Desktop to factory defaults
- [ ] **Virtualization disabled**: Enable in BIOS/UEFI settings
- [ ] **Memory allocation**: Increase Docker Desktop memory limit in settings
- [ ] **Drive sharing**: Enable drive sharing in Docker Desktop settings
- [ ] **Firewall/Antivirus**: Add Docker Desktop to exclusions

### Windows Script Execution
- [ ] **PowerShell execution policy**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- [ ] **Git Bash alternative**: Use Git Bash to run shell scripts on Windows
- [ ] **WSL alternative**: Run scripts inside WSL 2 environment

### Performance Optimization
- [ ] Verify BuildKit cache mounts are working
- [ ] Check available disk space for Docker
- [ ] Monitor build times for optimization opportunities

## 📋 Development Workflow Checklist

### Daily Development
- [ ] Start container: `./local.sh`
- [ ] Work in R environment
- [ ] Install packages as needed with renv
- [ ] Exit container when done

### Package Management
- [ ] Install new packages: `renv::install("package")`
- [ ] Update lockfile: `renv::snapshot()`
- [ ] Rebuild container if packages changed: `./build.sh`

### Team Collaboration
- [ ] Build and tag for sharing: `./build.sh`
- [ ] Push to Docker Hub (if configured)
- [ ] Team members pull: `./hub.sh`


## 🔄 Maintenance Checklist

### Regular Maintenance
- [ ] Update Docker Engine periodically
- [ ] Clean up unused images: `docker image prune`
- [ ] Clean up build cache: `docker buildx prune`
- [ ] Update base images in Containerfile

### Monitoring
- [ ] Check Docker disk usage: `docker system df`
- [ ] Monitor container resource usage
- [ ] Keep track of build times for performance regression

---

## 📝 Notes

**Key Advantage**: This approach eliminates the need to install R, system libraries, or build tools on the host system. Everything is containerized and reproducible.

**Recommended Workflow**: Build once, run anywhere. The container encapsulates the entire R development environment.

**Team Benefits**: Identical environments across all team members regardless of their host OS or existing R installations.
