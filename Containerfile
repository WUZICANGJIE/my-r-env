# syntax = docker/dockerfile:1
# Alternative Containerfile that reads dependencies directly from files
# This approach copies dependency files and reads them during build

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_CACHE_DIR=/var/cache/buildkit/pip
ENV RENV_PATHS_CACHE=/renv/cache

# --- 1. Copy dependency definitions ---
COPY deps/ /tmp/deps/

# --- 2. Load dependencies and install packages ---
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    mkdir -p $PIP_CACHE_DIR $RENV_PATHS_CACHE && \
    # Load dependencies from files using bash
    bash -c ". /tmp/deps/load-docker.sh && \
    # Install all dependencies
    apt-get update && apt-get install -y --no-install-recommends \
    \$RUNTIME_DEPS \
    \$BUILD_DEPS \
    \$DEV_LIBS_REMOVABLE \
    \$DEV_LIBS_REQUIRED" \
    && rm -rf /var/lib/apt/lists/*

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

RUN --mount=type=cache,target=/renv/cache \
    R --vanilla -e "renv::restore()"

# --- 9. Remove build-time dependencies ---
RUN bash -c ". /tmp/deps/load-docker.sh && \
    apt-get update && apt-get purge -y --auto-remove \
    \$BUILD_DEPS \
    \$DEV_LIBS_REMOVABLE" \
    && rm -rf /var/lib/apt/lists/* /tmp/deps && \
    apt-get clean

# --- 10. Configure Starship prompt ---
RUN mkdir -p /root/.config && \
    starship preset no-nerd-font -o /root/.config/starship.toml && \
    mkdir -p /root/.config/fish && \
    printf 'set fish_greeting ""\nstarship init fish | source\n' > /root/.config/fish/config.fish

CMD ["fish"]
