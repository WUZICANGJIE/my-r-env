# My Portable R Development Environment

This repository contains the configuration files to build a consistent, portable, and cross-platform R development environment using Podman and Distrobox. It is designed to be managed with Git and synchronized across multiple machines, including x86_64 Linux desktops and ARM64 devices running WSL.

Identical **local** environment everywhere.

**Disclaimer:** This project is primarily for my personal use. While it is designed to work across different environments, I cannot guarantee its functionality or provide support for all possible setups.

## Features

- **R**: Latest version from CRAN.
- **Core R Packages**: Essential packages are pre-installed (via `install_essentials.R`).
- **Additional R Packages**: A curated list of addon packages from CRAN and GitHub are also included (via `install_addons.R` and `install_github.R`).
- **Python & Radian**: Includes Python and the `radian` R console for an enhanced command-line experience.
- **PDF Generation**: Comes with a LaTeX distribution for rendering RMarkdown to PDF.
- **Cross-Platform**: Works on both `x86_64` and `arm64` (aarch64) architectures.
- **Automated**: Uses a setup script (`setup.sh`) for one-command deployment.

## Prerequisites

On each machine, you need to install:
1.  **Git**: To clone this repository.
2.  **Podman**: The container engine.
3.  **Distrobox**: The container manager.

## The Workflow

The core idea is to build an architecture-specific image on each machine (`x86_64`, `arm64`) and push them to the **same tag** in a container registry (like Docker Hub). The registry will combine them into a single multi-arch manifest.

### A. Initial Setup (First Time on Each Architecture)

1.  **Clone this repository:**
    ```bash
    git clone [https://github.com/wuzicangjie/my-r-environment.git](https://github.com/wuzicangjie/my-r-environment.git)
    cd my-r-environment
    ```

2.  **Edit `setup.sh`:**
    Open `setup.sh` and change the `DOCKERHUB_USERNAME` variable to your actual Docker Hub username.

3.  **Run the setup script:**
    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```
    - The script will first build the image locally.
    - It will then ask you if you want to push the image. **For the initial setup on each architecture, you must answer `y` (yes)**. This will upload the architecture-specific version to your Docker Hub repository.

4.  **Repeat on other architectures:**
    Go to your other machine (e.g., the ARM device), clone the repo, and run the same `./setup.sh` script. When you push, Docker Hub will automatically add the ARM version to your existing image tag.

### B. Deploying on a New Machine

Once your multi-arch image exists on Docker Hub, setting up a new machine is incredibly simple:

1.  Clone the repository.
2.  Run `./setup.sh`.
3.  When asked to push, you can answer `n` (no), as the script will use the image already available on Docker Hub to create your local container.

### C. Updating the Environment

1.  **Modify Configuration Files**:
    *   For **system packages** (e.g., `apt` packages, Python, LaTeX), edit the `Containerfile`.
    *   For **core R packages**, modify `install_essentials.R`.
    *   For **additional CRAN R packages**, modify `install_addons.R`.
    *   For **R packages from GitHub**, modify `install_github.R`.

2.  **Test Locally**:
    Run `./setup.sh` on your current machine. This will rebuild the image with your changes and create a new local container for testing. Answer `n` (no) when asked if you want to push the image, unless you are ready to update the image on Docker Hub.

3.  **Commit and Push Changes to Git**:
    Once you are satisfied with the changes:
    ```bash
    git add . # Add all changes
    git commit -m "Update environment" # Or a more descriptive message
    git push
    ```

4.  **Update All Machines & Docker Hub Image**:
    *   On your **current machine**, re-run `./setup.sh`. This time, when asked if you want to push the image, answer `y` (yes) to update the Docker Hub image for the current architecture.
    *   On your **other machines (different architectures)**:
        1.  Pull the latest changes from Git: `git pull`
        2.  Re-run `./setup.sh`. Answer `y` (yes) to push, which will update the multi-arch manifest on Docker Hub with the image for that specific architecture.

    This process ensures all your local environments are updated and the multi-arch image on Docker Hub reflects the latest configuration for all architectures.
