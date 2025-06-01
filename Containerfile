# Filename: Containerfile
# ========================
#
# Defines the complete R development environment.
# This file is architecture-agnostic and will work on both x86_64 and ARM64.

# Use the Long-Term Support version of Ubuntu as a stable base.
# The `ubuntu` image on Docker Hub is multi-arch, so it will pull the correct version automatically.
FROM ubuntu:24.04

# Set non-interactive frontend to avoid prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive

# --- 1. Install System Dependencies & Basic Tools ---
# Install essential tools required for adding repositories, managing software, and general development.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    software-properties-common \
    gnupg \
    dirmngr \
    curl \
    wget \
    git \
    make \
    cmake \
    unzip \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libmagick++-dev \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# --- 2. Install the latest version of R from CRAN ---
# Following the official instructions from CRAN for Ubuntu ensures we get the latest R version.
RUN apt-get update && apt-get install -y --no-install-recommends wget
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt-get update && apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# --- 4. Install Python and radian ---
# Install Python, pip, and then radian for an alternative R console.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --break-system-packages radian

# --- 5. Install LaTeX for RMarkdown PDF Output ---
# Install a comprehensive but not bloated TeX Live distribution.
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    lmodern \
    texlive-lang-cjk \
    latexmk && \
    rm -rf /var/lib/apt/lists/*

# --- 3. Install R Packages ---
COPY install_essentials.R /tmp/install_essentials.R
RUN Rscript /tmp/install_essentials.R && rm /tmp/install_essentials.R

COPY install_addons.R /tmp/install_addons.R
RUN Rscript /tmp/install_addons.R && rm /tmp/install_addons.R

COPY install_github.R /tmp/install_github.R
RUN Rscript /tmp/install_github.R && rm /tmp/install_github.R

# --- 6. Final Cleanup ---
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set a default command
CMD ["/bin/bash"]
