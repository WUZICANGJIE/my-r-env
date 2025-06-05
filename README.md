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
./test.sh

# 2. Build the container locally
./build.sh

# 3. Run the container for development
./local.sh

# Or pull from Docker Hub (if available)
./hub.sh
```

### Cross-Platform Setup

The `test.sh` script automatically handles setup for:
- **Linux**: Debian/Ubuntu, Arch, Fedora/RHEL/CentOS
- **macOS**: With Homebrew or Docker Desktop
- **Windows**: WSL (Windows Subsystem for Linux)

**First time?** Just run `./test.sh` and follow the prompts!

## 📁 Project Structure

```
my-r-env/
├── 🐳 Container Configuration
│   ├── Containerfile          # Optimized Docker build configuration
│   ├── build.sh              # Build script with Docker Hub integration
│   ├── local.sh              # Local development runner
│   ├── hub.sh                # Docker Hub runner
│   └── test.sh               # Container testing script
│
├── 📦 Dependency Management
│   └── deps/                 # Centralized system dependency definitions
│       ├── build.txt         # Build-time dependencies (removed after)
│       ├── removable.txt     # Dev libraries (removable)
│       ├── required.txt      # Dev libraries (required by R)
│       ├── runtime.txt       # Runtime dependencies (always kept)
│       ├── load.sh           # Dependency loader for scripts
│       ├── load-docker.sh    # Docker-specific loader
│       ├── gen-args.sh       # Generate Containerfile ARGs
│       ├── update.sh         # Update Containerfile with deps
│       ├── validate.sh       # Validate dependency files
│       └── README.md         # Dependency documentation
│
├── 🔧 R Environment
│   ├── .Rprofile             # R startup configuration
│   ├── renv.lock             # Package lockfile
│   ├── renv/                 # renv configuration
│   │   ├── activate.R        # renv activation script
│   │   └── settings.json     # renv settings
│   └── init_renv.R           # Package initialization script
│
├── 🐛 Development Tools
│   └── debug.sh              # Dependency debugging script
│
└── 🗄️ Backup & Archive
    └── .backup/              # Legacy files and backups
```

## 🔧 Scripts Overview

### Core Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `test.sh` | **Cross-platform setup & validation** | `./test.sh` |
| `build.sh` | Build container with Docker Hub integration | `./build.sh` |
| `local.sh` | Run container locally with cache mounts | `./local.sh` |
| `hub.sh` | Pull and run from Docker Hub | `./hub.sh` |
| `debug.sh` | Debug system dependencies | `./debug.sh` |

#### Setup Script Features
The `test.sh` script provides comprehensive environment validation:
- **OS Detection**: Automatically detects Linux distributions, macOS, and WSL
- **Docker Management**: Installs and configures Docker if missing
- **System Validation**: Checks disk space, memory, and dependencies
- **Project Validation**: Ensures all required files are present and valid
- **Interactive Setup**: Guides through the entire setup process

### Dependency Management

| Script | Purpose | Usage |
|--------|---------|-------|
| `deps/update.sh` | Update Containerfile with latest deps | `./deps/update.sh` |
| `deps/validate.sh` | Validate all dependency files | `./deps/validate.sh` |
| `deps/gen-args.sh` | Generate Containerfile ARGs | `./deps/gen-args.sh` |

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
./build.sh
```

## 🔄 Development Workflow

### Basic Development Cycle

```bash
# 1. Start development environment
./local.sh

# 2. Work in R session
R  # or radian for enhanced console

# 3. Install packages as needed
renv::install("new_package")
renv::snapshot()

# 4. Exit and rebuild if packages changed
exit
./build.sh  # Only if packages were added/updated
```

### Team Collaboration

```bash
# Team lead: Share environment
./build.sh                    # Build locally
# Select 'y' to push to Docker Hub

# Team members: Use shared environment
./hub.sh                      # Pull and run from Docker Hub
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

### Docker Hub Integration

1. **Configure username** in `build.sh`:
   ```bash
   DOCKERHUB_USERNAME="your-username"
   ```

2. **Build and push**:
   ```bash
   ./build.sh
   # Choose 'y' when prompted to push
   ```

3. **Use on other machines**:
   ```bash
   ./hub.sh
   ```

### Manual Docker Commands

```bash
# Build manually
docker build -t my-r-env -f Containerfile .

# Run with proper mounts
docker run -it --rm \
  -e "RENV_PATHS_CACHE=/renv/cache" \
  -v "$HOME/.cache/R/renv:/renv/cache" \
  -v "$(pwd):/project" \
  -w /project \
  my-r-env
```

### System Dependencies

The centralized dependency management system allows easy modification of system packages:

```bash
# Edit dependency files
vim deps/runtime.txt      # Add runtime dependencies
vim deps/build.txt        # Add build tools
vim deps/required.txt     # Add required dev libraries

# Update container
./deps/update.sh          # Update Containerfile
./deps/validate.sh        # Validate changes
./build.sh               # Rebuild container
```

## 🔍 Troubleshooting

### Common Issues

**Setup script fails:**
- Run with `./test.sh --help` to see all options
- Use `./test.sh --skip-docker` if Docker is already configured
- Check permissions: `chmod +x test.sh`

**Docker installation issues:**
- On WSL: Ensure Docker Desktop is running on Windows
- On Linux: You may need to log out and back in after installation
- Manual installation: See [Docker docs](https://docs.docker.com/engine/install/)

**Docker daemon not running:**
- Script will detect and offer to start Docker daemon
- On WSL: Either start Docker Desktop on Windows or start service in WSL
- On Linux: Script can attempt `sudo systemctl start docker`

**Container name conflicts:**
- `local.sh` automatically removes existing containers

**Build performance:**
- Setup script automatically enables Docker BuildKit
- Check cache status: `docker system df`

**Package issues:**
- Reset renv: `renv::restore()`
- Clear cache: `rm -rf ~/.cache/R/renv`

### Debug Tools

```bash
# Complete system setup and validation
./test.sh

# System setup without prompting for build
./test.sh --no-build

# Skip Docker checks (if already configured)
./test.sh --skip-docker

# Debug system dependencies
./debug.sh

# Validate dependency files
./deps/validate.sh

# Check Docker cache usage
docker buildx du
```

## 📚 Additional Resources

- **Dependency Management**: See `deps/README.md` for detailed documentation
- **renv Documentation**: https://rstudio.github.io/renv/
- **Docker BuildKit**: https://docs.docker.com/develop/dev-best-practices/

## 🤝 Contributing

1. Fork the repository
2. Make changes and test with `./build.sh`
3. Update documentation if needed
4. Submit a pull request

---

**Ready to develop?** Run `./build.sh` followed by `./local.sh` to get started with your reproducible R environment! 🎉
