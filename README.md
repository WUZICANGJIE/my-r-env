# R Development Environment with Docker

A modern, containerized R development environment featuring reproducible package management, optimized builds, and enhanced developer experience.

## ✨ Features

- **R 4.5.0** with comprehensive package ecosystem
- **renv** for reproducible package management
- **Fish shell** with Starship prompt for modern terminal experience
- **Python + radian** for enhanced R console
- **LaTeX** support for RMarkdown PDF output
- **Docker BuildKit** optimizations for fast rebuilds
- **Multi-architecture support** (amd64/arm64)
- **Centralized dependency management** system

## 🚀 Quick Start

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
│   ├── Dockerfile            # Optimized Docker build configuration
│   ├── docker-build.sh      # Build script with Docker Hub integration
│   ├── docker-run-local.sh  # Local development runner
│   ├── docker-run-hub.sh    # Docker Hub runner
│   ├── env-setup.sh         # Environment setup and validation
│   └── env-verify.sh        # Container verification script
│
├── 📦 Dependency Management
│   └── system-packages.txt          # System dependencies (apt packages)
│
├── 🔧 R Environment
│   ├── .Rprofile             # R startup configuration
│   ├── renv.lock             # Package lockfile
│   ├── renv/                 # renv configuration
│   │   ├── activate.R        # renv activation script
│   │   └── settings.json     # renv settings
│   └── init_renv.R           # Package initialization script
│
└── 🗄️ Backup & Archive
    └── .backup/              # Legacy files and backups
```

## 🔧 Scripts Overview

### Core Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `env-setup.sh` | **Cross-platform setup & validation** | `./env-setup.sh` |
| `docker-build.sh` | Build container with Docker Hub integration | `./docker-build.sh` |
| `docker-run-local.sh` | Run container locally with cache mounts | `./docker-run-local.sh` |
| `docker-run-hub.sh` | Pull and run from Docker Hub | `./docker-run-hub.sh` |
| `env-verify.sh` | Verify container environment | `./env-verify.sh` |

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

## 🐳 Container Features

### Build Optimizations
- **BuildKit cache mounts** for faster rebuilds
- **Multi-stage dependency management** 
- **Selective cleanup** of build dependencies
- **renv cache persistence** across container rebuilds

### Runtime Environment
- **Fish shell** with custom configuration
- **Starship prompt** with no-nerd-font preset
- **radian** for enhanced R console experience
- **LaTeX** for document generation
- **Volume mounts** for project persistence

### Architecture Support
- **Multi-architecture builds** (amd64/arm64)
- **Architecture-specific tagging** for Docker Hub
- **Automatic manifest creation** for universal images

## 📦 Package Management

### Current R Packages
The environment includes a curated set of R packages managed through renv:

**Core Development:**
- tidyverse, devtools, rmarkdown, shiny
- data.table, ggplot2, languageserver

**Data Analysis:**
- psych, broom, forecast, car
- modelsummary, lmtest, zoo, moments

**Data Import/Export:**
- readxl, countrycode, comtradr
- rsdmx, quantmod, wbstats

**Visualization & Tables:**
- gt, kableExtra, coefplot, stargazer

**Statistical Methods:**
- estimatr, optionstrat, fUnitRoots, strucchange

### Adding Packages

```r
# Inside the container
renv::install("package_name")    # Install from CRAN
renv::install("user/repo")       # Install from GitHub
renv::snapshot()                 # Update lockfile

# Rebuild container to persist
exit
./docker-build.sh
```

## 🔄 Development Workflow

### Basic Development Cycle

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
- **75-80% faster** rebuilds when no changes
- **50% faster** when only renv.lock changes
- **BuildKit cache mounts** for all package managers

### Cache Strategy
```dockerfile
# APT package cache
RUN --mount=type=cache,target=/var/cache/apt

# Python pip cache
RUN --mount=type=cache,target=/var/cache/buildkit/pip

# renv package cache
RUN --mount=type=cache,target=/renv/cache
```

### Host Cache Locations
- **renv packages**: `~/.cache/R/renv` → `/renv/cache`
- **Build persistence** across container rebuilds
- **Shared cache** across different projects

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

**Build performance:**
- Setup script automatically enables Docker BuildKit
- Check cache status: `docker system df`
- Use debug mode to troubleshoot build issues: `--build-arg KEEP_DEPS=true`

**Package issues:**
- Reset renv: `renv::restore()`
- Clear cache: `rm -rf ~/.cache/R/renv`

### Debug Tools

```bash
# Complete system setup and validation
./env-setup.sh

# System setup without prompting for build
./env-setup.sh --no-build

# Skip Docker checks (if already configured)
./env-setup.sh --skip-docker

# Verify container environment
./env-verify.sh

# Check Docker cache usage
docker buildx du
```

## 📚 Additional Resources

- **System Dependencies**: Managed via `system-packages.txt` file
- **renv Documentation**: https://rstudio.github.io/renv/
- **Docker BuildKit**: https://docs.docker.com/develop/dev-best-practices/

## 🤝 Contributing

1. Fork the repository
2. Make changes and test with `./docker-build.sh`
3. Update documentation if needed
4. Submit a pull request

---

**Ready to develop?** Run `./docker-build.sh` followed by `./docker-run-local.sh` to get started with your reproducible R environment! 🎉
