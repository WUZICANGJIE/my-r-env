# My Portable R Development Environment

This repository provides configuration files for a consistent, portable, and cross-platform R development environment using Podman and Distrobox. It's designed for Git-based management and synchronization across multiple machines (x86_64 Linux, ARM64 WSL).

The goal is an identical **local** R environment everywhere.

**Disclaimer:** This is a personal project. Functionality across all setups is not guaranteed.

## Features

- **R**: Latest version from CRAN.
- **Core R Packages**: Pre-installed via `install_essentials.R`.
- **Additional R Packages**: Curated addons from CRAN (`install_addons.R`) and GitHub (`install_github.R`).
- **Python & Radian**: Includes Python and the `radian` R console.
- **PDF Generation**: LaTeX for RMarkdown to PDF.
- **Cross-Platform**: Works on `x86_64` and `arm64` (aarch64).
- **Automated Setup & Deployment**:
    - `setup.sh`: For initial environment setup, building the image, and updating it.
    - `deploy.sh`: For quickly deploying the existing image from Docker Hub to a new machine.

## Prerequisites

On each machine:
1.  **Git**
2.  **Podman**
3.  **Distrobox**

## The Workflow

The core idea is to build architecture-specific images (`x86_64`, `arm64`) on each machine and push them to the **same tag** on Docker Hub. Docker Hub creates a multi-arch manifest.

### A. Initial Setup (First Time on Each Architecture)

1.  **Clone this repository:**
    ```bash
    git clone https://github.com/wuzicangjie/my-r-environment.git # Replace with your repo URL if forked
    cd my-r-environment
    ```

2.  **Configure Docker Hub Username:**
    Open `setup.sh` and set the `DOCKERHUB_USERNAME` variable to your Docker Hub username.

3.  **Run the setup script:**
    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```
    - The script builds the image locally.
    - When prompted to push, answer `y` (yes) for the initial setup on *each different architecture* to upload the specific version to Docker Hub.

4.  **Repeat on other architectures:**
    On your other machines (e.g., an ARM device), clone the repo, configure `DOCKERHUB_USERNAME` in `setup.sh`, and run `./setup.sh`, pushing the image.

### B. Deploying on a New Machine (Using an Existing Image)

Once your multi-arch image is on Docker Hub:

1.  **Clone the repository.**
2.  **Configure Docker Hub Username:**
    Open `deploy.sh` and set the `DOCKERHUB_USERNAME` variable to your Docker Hub username.
3.  **Run the deployment script:**
    ```bash
    chmod +x deploy.sh
    ./deploy.sh
    ```
    This script pulls the appropriate image from Docker Hub and sets up the Distrobox container.

### C. Updating the Environment

1.  **Modify Configuration Files**:
    *   System packages (e.g., `apt`, Python, LaTeX): `Containerfile`.
    *   Core R packages: `install_essentials.R`.
    *   Additional CRAN R packages: `install_addons.R`.
    *   R packages from GitHub: `install_github.R`.

2.  **Test Locally**:
    Run `./setup.sh` on your current machine. Answer `n` (no) when asked to push, unless you're ready to update the Docker Hub image. This rebuilds and tests the image locally.

3.  **Commit and Push Changes to Git**:
    ```bash
    git add .
    git commit -m "Update environment: [your changes]"
    git push
    ```

4.  **Update Docker Hub Image & All Machines**:
    *   **Current Machine**:
        1.  Ensure `DOCKERHUB_USERNAME` is set in `setup.sh`.
        2.  Re-run `./setup.sh`. Answer `y` (yes) to push, updating the Docker Hub image for the current architecture.
    *   **Other Machines (different architectures)**:
        1.  `git pull` to get the latest configuration.
        2.  Ensure `DOCKERHUB_USERNAME` is set in `setup.sh`.
        3.  Re-run `./setup.sh`. Answer `y` (yes) to push, updating the multi-arch manifest on Docker Hub with the image for that architecture.

This process keeps local environments and the multi-arch Docker Hub image synchronized.
