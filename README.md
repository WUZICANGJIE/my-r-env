# R Development Environment with Docker

> ⚠️ **DISCLAIMER**: This project is currently very buggy and is intended for my personal use only. 

A modern, containerized R development environment featuring reproducible package management, optimized builds, and enhanced developer experience. Designed for data scientists, statisticians, and R developers who need a consistent, portable, and fully-featured development environment.

## ✨ Features

- **R 4.5.0** with comprehensive package ecosystem (270+ packages)
- **renv** for reproducible package management with **pre-installed essential packages**
- **Built-in renv configuration** - `renv.lock`, `activate.R`, and `settings.json` embedded in container
- **Fish shell** with Starship prompt for modern terminal experience
- **Python + radian** for enhanced R console with syntax highlighting
- **LaTeX** support for RMarkdown PDF output
- **VS Code integration** with pre-installed extensions
- **Docker BuildKit** optimizations for 75-80% faster rebuilds
- **Multi-architecture support** (amd64/arm64)
- **Docker Compose** support for seamless VS Code development
- **Centralized dependency management** system

## 🚀 Quick Start

### Option 1: VS Code Development Container (Recommended)

```bash
# 1. Clone and open in VS Code
git clone <repository-url>
cd my-r-env
code .

# 2. When prompted, click "Reopen in Container"
# Or use Command Palette: "Dev Containers: Reopen in Container"
```

### Option 2: Standalone Container

```bash
# 1. First-time setup (validates system and installs Docker if needed)
./env-setup.sh

# 2. Build the container locally
./docker-build.sh

# 3. Run the container for development
./docker-run-local.sh

# Or pull from Docker Hub (if available)
./docker-run-hub.sh
```

### Option 3: Docker Compose

```bash
# Start the environment
docker-compose up -d

# Attach to the container
docker exec -it r-env-vscode fish
```

### Cross-Platform Setup

The `env-setup.sh` script automatically handles setup for:
- **Linux**: Debian/Ubuntu, Arch, Fedora/RHEL/CentOS
- **macOS**: With Homebrew or Docker Desktop
- **Windows**: WSL (Windows Subsystem for Linux)

**First time?** Just run `./env-setup.sh` and follow the prompts!

## 📁 Project Structure

```
my-r-env/
├── 🐳 Container Configuration
│   ├── Dockerfile              # Multi-stage optimized Docker build
│   ├── docker-compose.yml      # VS Code development container setup
│   ├── docker-build.sh         # Build script with Docker Hub integration
│   ├── docker-run-local.sh     # Local development runner
│   ├── docker-run-hub.sh       # Docker Hub runner
│   ├── docker-push.sh          # Docker Hub publishing script
│   └── env-setup.sh            # Cross-platform setup and validation
│
├── 📦 Dependency Management
│   ├── system-packages.txt     # System dependencies (apt packages)
│   ├── renv.lock              # R package lockfile (270+ packages) - **EMBEDDED IN CONTAINER**
│   └── renv/                  # renv configuration and cache - **EMBEDDED IN CONTAINER**
│       ├── activate.R         # renv activation script - **EMBEDDED IN CONTAINER**
│       ├── settings.json      # renv settings - **EMBEDDED IN CONTAINER**
│       └── library/           # Installed R packages
│
├── 🔧 Development Environment
│   ├── .devcontainer/         # VS Code dev container configuration
│   │   └── devcontainer.json  # Dev container settings
│   ├── .Rprofile              # R startup configuration
│   ├── config.fish            # Fish shell configuration
│   ├── install-extensions.sh  # VS Code extensions installer
│   └── init_renv.R            # R package initialization script
│
├── 📊 Logs & Monitoring
│   └── logs/                  # Build and verification logs
│       ├── verification.log   # Container verification results
│       └── verification_summary.log
│
└── 📋 Project Management
    ├── .checklist/            # Project tracking and TODO items
    ├── .github/               # GitHub Actions and templates
    └── LICENSE                # MIT License
```

## 🔧 Scripts Overview

### Core Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `env-setup.sh` | **Cross-platform setup & validation** | `./env-setup.sh` |
| `docker-build.sh` | Build container with Docker Hub integration | `./docker-build.sh` |
| `docker-run-local.sh` | Run container locally with cache mounts | `./docker-run-local.sh` |
| `docker-run-hub.sh` | Pull and run from Docker Hub | `./docker-run-hub.sh` |
| `docker-push.sh` | Push built image to Docker Hub | `./docker-push.sh` |
| `docker-compose.yml` | **VS Code dev container configuration** | `docker-compose up -d` |

#### VS Code Development Container

The project includes full VS Code development container support:

- **devcontainer.json**: Configures VS Code to use the Docker Compose setup
- **Automatic setup**: Opens directly in containerized environment
- **Extension management**: Pre-installs 30+ extensions for R, Python, and data science
- **Volume persistence**: Maintains R package cache and project files
- **Docker-in-Docker**: Enables running Docker commands from within the container

#### Setup Script Features
The `env-setup.sh` script provides comprehensive environment validation:
- **OS Detection**: Automatically detects Linux distributions, macOS, and WSL
- **Docker Management**: Installs and configures Docker if missing
- **System Validation**: Checks disk space, memory, and dependencies
- **Project Validation**: Ensures all required files are present and valid
- **Interactive Setup**: Guides through the entire setup process

### Dependency Management

| File | Purpose | Usage |
|------|---------|-------|
| `system-packages.txt` | System dependencies (apt packages) | Edit directly, then rebuild |
| `renv.lock` | **R package lockfile (270+ packages)** | Managed by renv |
| `install-extensions.sh` | VS Code extensions installer | Runs during Docker build |

## 🐳 Container Features

### Build Optimizations
- **BuildKit cache mounts** for faster rebuilds (75-80% improvement)
- **Multi-stage dependency management** with selective cleanup
- **Persistent renv cache** across container rebuilds
- **Layered package installation** for optimal Docker layer caching
- **Architecture-aware builds** (amd64/arm64)

### Runtime Environment
- **Fish shell** with custom configuration and Starship prompt
- **radian** as the default R interface with syntax highlighting, completion, and auto-renv management
- **Automatic renv handling**: Auto-initialization and restoration based on project state
- **VS Code Server** with 30+ pre-installed extensions
- **LaTeX** for RMarkdown PDF generation
- **Docker-in-Docker** capability for containerized workflows
- **Volume mounts** for project and cache persistence

### VS Code Integration
- **Development Container**: Full VS Code development environment
- **Extension Management**: Automatic installation of R, Python, and data science extensions
- **Integrated Terminal**: Fish shell with enhanced R console (radian as default)
- **Automatic renv Management**: Auto-initialization and restoration on container startup
- **IntelliSense**: Advanced R language server and Python support
- **Git Integration**: Built-in Git support with GitHub integration

### Architecture Support
- **Multi-architecture builds** (amd64/arm64)
- **Architecture-specific tagging** for Docker Hub
- **Automatic manifest creation** for universal images

## 📦 Package Management

### Built-in renv Configuration (Cross-Platform Reproducibility)

**🚀 NEW**: The container now includes pre-configured renv files that are automatically available when you start the container on any machine:

- **`renv.lock`**: Exact package versions for 270+ packages including `tidyverse`, `languageserver`, and `httpgd`
- **`renv/activate.R`**: Automatic renv initialization in any R session
- **`renv/settings.json`**: Pre-configured renv settings for optimal behavior

**Key Benefits:**
- ✅ **Instant availability**: Essential packages ready immediately on any computer
- ✅ **Perfect reproducibility**: Same package versions across all environments  
- ✅ **Zero configuration**: Works out-of-the-box for new projects
- ✅ **Team consistency**: Identical development environment for all team members

### Current R Packages (270+ installed)
The environment includes a comprehensive, production-ready set of R packages managed through renv:

**Core Development & IDE:**
- tidyverse, devtools, rmarkdown, shiny, languageserver
- data.table, ggplot2, dplyr, httpgd (for VS Code plotting)

**Statistical Analysis:**
- psych, broom, forecast, car, lmtest, zoo, moments
- estimatr, bayestestR, insight, datawizard

**Data Import/Export:**
- readxl, haven, DBI, dbplyr, googledrive, googlesheets4
- countrycode, comtradr, rsdmx, quantmod, wbstats

**Visualization & Tables:**
- gt, kableExtra, coefplot, stargazer, cowplot
- htmlwidgets, dygraphs, crosstalk

**Advanced Methods:**
- optionstrat, fUnitRoots, strucchange, fBasics
- GPArotation, experimentdatar

**Development Tools:**
- testthat, roxygen2, pkgdown, usethis, gitcreds
- lintr, styler, profvis, bench

### Adding Packages

#### In VS Code Development Container
```r
# Open R console in VS Code terminal or use Jupyter notebooks
# Essential packages (tidyverse, languageserver, httpgd) are already available!

renv::install("package_name")    # Install from CRAN
renv::install("user/repo")       # Install from GitHub
renv::snapshot()                 # Update lockfile
```

#### In Standalone Container
```r
# Inside the container
# Essential packages (tidyverse, languageserver, httpgd) are already available!

renv::install("package_name")    # Install from CRAN
renv::install("user/repo")       # Install from GitHub
renv::snapshot()                 # Update lockfile

# Exit and rebuild container to persist
exit
./docker-build.sh
```

### Package Cache System
- **Essential packages**: Pre-installed in container (`tidyverse`, `languageserver`, `httpgd`, etc.)
- **Host cache**: `~/.cache/R/renv` → `/renv/cache` (persistent across rebuilds)
- **Container cache**: Optimized with Docker BuildKit cache mounts
- **renv library**: `renv/library/` (version-specific installations)

## 🔄 Development Workflow

### VS Code Development Container (Recommended)

```bash
# 1. Open project in VS Code
code /home/wuzi/Documents/Scripts/my-r-env

# 2. When prompted, select "Reopen in Container"
# Or use Command Palette (Ctrl+Shift+P): "Dev Containers: Reopen in Container"

# 3. VS Code will automatically:
#    - Build the container (if needed)
#    - Install extensions
#    - Set up the development environment
#    - Open integrated terminal with Fish shell

# 4. Start working with R
# Option A: Use R in the integrated terminal
R  # or radian for enhanced console

# Option B: Use Jupyter notebooks
# Create new .ipynb file and select R kernel

# Option C: Use R Markdown
# Create .Rmd files with full rendering support
```

### Standalone Development Cycle

```bash
# 1. Start development environment
./docker-run-local.sh

# 2. Work in R session
R  # or radian for enhanced console

# 3. Install packages as needed
renv::install("new_package")
renv::snapshot()

# 4. Exit and rebuild if packages changed
exit
./docker-build.sh  # Only if packages were added/updated
```

### Docker Compose Workflow

```bash
# 1. Start the environment
docker-compose up -d

# 2. Attach to the container
docker exec -it r-env-vscode fish

# 3. Work with R
radian  # Enhanced R console

# 4. Stop when done
docker-compose down
```

### Team Collaboration

```bash
# Team lead: Share environment
./docker-build.sh             # Build locally
# Select 'y' to push to Docker Hub

# Team members: Use shared environment
./docker-run-hub.sh           # Pull and run from Docker Hub
```

## ⚡ Performance Features

### Build Speed Optimizations
- **75-80% faster** rebuilds when no changes detected
- **50% faster** when only renv.lock changes
- **BuildKit cache mounts** for all package managers (APT, pip, renv)
- **Multi-stage builds** with intelligent layer caching
- **Parallel package installation** where possible

### Cache Strategy
```dockerfile
# APT package cache (system packages)
RUN --mount=type=cache,target=/var/cache/apt

# Python pip cache (radian and dependencies)
RUN --mount=type=cache,target=/var/cache/buildkit/pip

# renv package cache (R packages)
RUN --mount=type=cache,target=/renv/cache
```

### Host Cache Locations
- **renv packages**: `~/.cache/R/renv` → `/renv/cache`
- **Docker BuildKit**: Automatic cache management
- **Build persistence** across container rebuilds
- **Shared cache** across different projects using the same base image

### Container Optimization
- **Multi-architecture support**: Single command works on Intel and ARM
- **Minimal runtime**: Debug dependencies removed in production builds
- **Layer optimization**: Frequently changing files placed in later layers

## 🛠️ Advanced Configuration

### Debug Mode

For debugging build issues or developing new features, you can build the container with all dependencies kept:

```bash
# Build in debug mode (keeps all build dependencies)
docker build --build-arg KEEP_DEPS=true -t my-r-env-debug .

# Or modify docker-build.sh to use debug mode
KEEP_DEPS=true ./docker-build.sh
```

**Debug mode differences:**
- All build tools and development libraries remain installed
- Larger image size but full debugging capabilities  
- Useful for troubleshooting dependency issues
- Package cache is still cleaned for efficiency

### Docker Hub Integration

1. **Configure username** in `docker-build.sh`:
   ```bash
   DOCKERHUB_USERNAME="your-username"
   ```

2. **Build and push**:
   ```bash
   ./docker-build.sh
   # Choose 'y' when prompted to push
   ```

3. **Use on other machines**:
   ```bash
   ./docker-run-hub.sh
   ```

### Manual Docker Commands

```bash
# Build manually
docker build -t my-r-env -f Dockerfile .

# Build in debug mode (keeps build dependencies)
docker build --build-arg KEEP_DEPS=true -t my-r-env-debug .

# Run with proper mounts
docker run -it --rm \
  -e "RENV_PATHS_CACHE=/renv/cache" \
  -v "$HOME/.cache/R/renv:/renv/cache" \
  -v "$(pwd):/project" \
  -w /project \
  my-r-env
```

### System Dependencies

System packages can be easily modified by editing the system-packages.txt file:

```bash
# Edit system dependencies
vim system-packages.txt             # Add/remove system packages

# Rebuild container with new dependencies
./docker-build.sh           # Rebuild container
```

## 🔍 Troubleshooting

### Common Issues

**VS Code Development Container:**
- **Container won't start**: Check Docker is running and has sufficient resources
- **Extensions not loading**: Container may still be building; wait for completion
- **R packages missing**: Run `renv::restore()` in the R console
- **Permission issues**: Ensure user mapping is correct (1000:1000)

**Setup script fails:**
- Run with `./env-setup.sh --help` to see all options
- Use `./env-setup.sh --skip-docker` if Docker is already configured
- Check permissions: `chmod +x env-setup.sh`

**Docker installation issues:**
- On WSL: Ensure Docker Desktop is running on Windows
- On Linux: You may need to log out and back in after installation
- Manual installation: See [Docker docs](https://docs.docker.com/engine/install/)

**Docker daemon not running:**
- Script will detect and offer to start Docker daemon
- On WSL: Either start Docker Desktop on Windows or start service in WSL
- On Linux: Script can attempt `sudo systemctl start docker`

**Container name conflicts:**
- `docker-run-local.sh` automatically removes existing containers
- For Docker Compose: `docker-compose down` before restarting

**Build performance:**
- Setup script automatically enables Docker BuildKit
- Check cache status: `docker system df`
- Use debug mode to troubleshoot build issues: `--build-arg KEEP_DEPS=true`

**Package installation issues:**
- Reset renv: `renv::restore()`
- Clear host cache: `rm -rf ~/.cache/R/renv`
- Check package installation logs in VS Code terminal

**VS Code Extension Issues:**
- Extensions install during container build (may take 5-10 minutes first time)
- If extensions fail to install, rebuild container: `docker-compose down && docker-compose up --build`
- Check logs: `docker logs r-env-vscode`

### Debug Tools

```bash
# Complete system setup and validation
./env-setup.sh

# System setup without prompting for build
./env-setup.sh --no-build

# Skip Docker checks (if already configured)
./env-setup.sh --skip-docker

# Check Docker cache usage
docker system df

# View container logs
docker logs r-env-vscode

# Rebuild everything from scratch
docker-compose down
docker system prune -a  # WARNING: Removes all Docker cache
./docker-build.sh
```

### Known Issues

**Current Status** (as of June 7, 2025):

1. **VS Code Extension Installation**: Some extensions may not install correctly during Docker build
   - **Workaround**: Extensions can be installed manually after container starts
   - **Status**: Investigating installation timing and permissions

2. **Cache Layer Testing**: Docker BuildKit cache layers need validation
   - **Status**: Testing in progress for optimal cache configuration

## 📚 Additional Resources

- **System Dependencies**: Managed via `system-packages.txt` file
- **renv Documentation**: https://rstudio.github.io/renv/
- **Docker BuildKit**: https://docs.docker.com/develop/dev-best-practices/
- **VS Code Dev Containers**: https://code.visualstudio.com/docs/devcontainers/containers
- **Fish Shell**: https://fishshell.com/docs/current/
- **Starship Prompt**: https://starship.rs/
- **radian (Enhanced R Console)**: https://github.com/randy3k/radian

### Project Files Reference

| File | Purpose | Documentation |
|------|---------|---------------|
| `Dockerfile` | Multi-stage container build | Docker best practices applied |
| `docker-compose.yml` | VS Code dev container setup | Uses published image from Docker Hub |
| `devcontainer.json` | VS Code dev container config | Minimal configuration for Docker Compose |
| `renv.lock` | R package versions (270+ packages) | Generated by renv::snapshot() |
| `system-packages.txt` | System dependencies | One package per line, comments with # |
| `config.fish` | Fish shell configuration | Includes renv activation and Starship |


---