# syntax = docker/dockerfile:1
# Simplified Containerfile with consolidated dependency management
# All system dependencies are defined in a single packages.txt file

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_CACHE_DIR=/var/cache/buildkit/pip
ENV RENV_PATHS_CACHE=/renv/cache

# --- 1. Copy dependency definitions ---
COPY packages.txt /tmp/packages.txt

# --- 2. Install system dependencies ---
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    mkdir -p $PIP_CACHE_DIR $RENV_PATHS_CACHE && \
    # Install all dependencies from single file
    apt-get update && \
    grep -v '^#' /tmp/packages.txt | grep -v '^$' | xargs apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* /tmp/packages.txt

# --- 3. Install R from CRAN ---
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt-get update && apt-get install -y --no-install-recommends \
    r-base=4.5.* \
    r-base-dev=4.5.* \
    && rm -rf /var/lib/apt/lists/*

# --- 4. Install Fish Shell ---
RUN add-apt-repository ppa:fish-shell/release-4 -y && \
    apt-get update && apt-get install -y --no-install-recommends \
    fish \
    && rm -rf /var/lib/apt/lists/*

# --- 5. Install Python and radian ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* && \
    pip3 install --break-system-packages radian

# --- 6. Install Starship prompt ---
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# --- 7. Install LaTeX ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    lmodern \
    texlive-lang-chinese \
    texlive-lang-japanese \
    latexmk \
    && rm -rf /var/lib/apt/lists/*

# --- 8. Install renv and setup R packages ---
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

WORKDIR /project

COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json
COPY init_renv.R init_renv.R

RUN --mount=type=cache,target=/renv/cache \
    # Check if renv.lock is empty or has no packages, then run init_renv.R
    if [ ! -s renv.lock ] || ! grep -q '"Packages"' renv.lock || [ "$(grep -c '"[^"]*".*{' renv.lock)" -le 1 ]; then \
        echo "renv.lock is empty or minimal, running init_renv.R to install packages..."; \
        R --vanilla -e "source('init_renv.R')"; \
    else \
        echo "renv.lock contains packages, restoring from lockfile..."; \
        R --vanilla -e "renv::restore()"; \
    fi && \
    # Create the hash file for tracking changes
    sha256sum init_renv.R | cut -d' ' -f1 > .init_renv_hash

# --- 9. Configure Starship prompt ---
RUN mkdir -p /root/.config && \
    starship preset no-nerd-font -o /root/.config/starship.toml && \
    mkdir -p /root/.config/fish && \
    printf 'set fish_greeting ""\nstarship init fish | source\n' > /root/.config/fish/config.fish

# --- 10. Start the shell ---
CMD ["fish"]
