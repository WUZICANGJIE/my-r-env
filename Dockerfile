# syntax = docker/dockerfile:1
# Simplified Dockerfile with consolidated dependency management
# All system dependencies are defined in a single system-packages.txt file

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_CACHE_DIR=/var/cache/buildkit/pip
ENV RENV_PATHS_CACHE=/renv/cache

# Locale environment variables with fallback support
ENV LOCALE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US:en

# --- 1. Copy dependency definitions ---
COPY system-packages.txt /tmp/system-packages.txt

# --- 2. Install system dependencies ---
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    mkdir -p $PIP_CACHE_DIR $RENV_PATHS_CACHE && \
    # Install all dependencies from system-packages.txt
    apt-get update -qq && \
    grep -v '^#' /tmp/system-packages.txt | grep -v '^$' | xargs apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* /tmp/system-packages.txt

# --- 2.1. Configure locales ---
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_TW.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# --- 3. Install R from CRAN ---
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    r-base=4.5.* \
    r-base-dev=4.5.* \
    && rm -rf /var/lib/apt/lists/*

# --- 4. Install Fish Shell ---
RUN add-apt-repository ppa:fish-shell/release-4 -y && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    fish \
    && rm -rf /var/lib/apt/lists/*

# --- 5. Install Python and radian ---
RUN --mount=type=cache,target=/var/cache/buildkit/pip \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* && \
    pip3 install --break-system-packages radian

# --- 6. Install Starship prompt ---
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# --- 7. Install LaTeX ---
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
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

RUN --mount=type=cache,target=${RENV_PATHS_CACHE} \
    R -e "renv::restore()"

# --- 9. Configure Starship prompt and Fish shell ---
COPY config.fish /tmp/config.fish
RUN mkdir -p /root/.config && \
    starship preset no-nerd-font -o /root/.config/starship.toml && \
    mkdir -p /root/.config/fish && \
    cp /tmp/config.fish /root/.config/fish/config.fish && \
    rm /tmp/config.fish

# --- 10. Start the shell ---
CMD ["fish"]
