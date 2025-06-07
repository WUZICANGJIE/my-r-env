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

# User configuration
ENV USER_NAME=wuzi

# --- 1. Copy dependency definitions ---
COPY system-packages.txt /tmp/system-packages.txt

# --- 2. Install system packages ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    mkdir -p $PIP_CACHE_DIR $RENV_PATHS_CACHE && \
    # Install all packages from system-packages.txt
    apt-get update -qq && \
    grep -v '^#' /tmp/system-packages.txt | grep -v '^$' | xargs apt-get install -y --no-install-recommends && \
    rm -f /tmp/system-packages.txt

# --- 3. Configure locales ---
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_TW.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# --- 4. Install R from CRAN ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    r-base=4.5.* \
    r-base-dev=4.5.*

# --- 5. Install Fish Shell ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    add-apt-repository ppa:fish-shell/release-4 -y && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    fish

# --- 6. Create non-root user ---
RUN groupadd --gid 1000 ${USER_NAME} && \
    useradd --uid 1000 --gid ${USER_NAME} --shell /usr/bin/fish --create-home ${USER_NAME} && \
    usermod -aG sudo ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# --- 7. Install Python packages ---
RUN --mount=type=cache,target=/var/cache/buildkit/pip \
    pip3 install --break-system-packages radian

# --- 8. Install Starship prompt ---
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# --- 9. Install VS Code (multiarch compatible) ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    rm -f packages.microsoft.gpg && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    code

# --- 10. Setup R environment ---
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Switch to non-root user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/project

COPY --chown=${USER_NAME}:${USER_NAME} renv.lock renv.lock
COPY --chown=${USER_NAME}:${USER_NAME} .Rprofile .Rprofile
COPY --chown=${USER_NAME}:${USER_NAME} renv/activate.R renv/activate.R
COPY --chown=${USER_NAME}:${USER_NAME} renv/settings.json renv/settings.json
COPY --chown=${USER_NAME}:${USER_NAME} init_renv.R init_renv.R

RUN --mount=type=cache,target=${RENV_PATHS_CACHE} \
    R -e "renv::restore()"

# --- 11. Configure Starship prompt and Fish shell ---
COPY --chown=${USER_NAME}:${USER_NAME} config.fish /tmp/config.fish
RUN mkdir -p /home/${USER_NAME}/.config && \
    starship preset no-nerd-font -o /home/${USER_NAME}/.config/starship.toml && \
    mkdir -p /home/${USER_NAME}/.config/fish && \
    cp /tmp/config.fish /home/${USER_NAME}/.config/fish/config.fish && \
    rm /tmp/config.fish

# --- 12. Install VS Code extensions ---
COPY --chown=${USER_NAME}:${USER_NAME} install-extensions.sh /tmp/install-extensions.sh
RUN chmod +x /tmp/install-extensions.sh && \
    mkdir -p /home/${USER_NAME}/.vscode-server/extensions && \
    bash -c '/tmp/install-extensions.sh' && \
    rm /tmp/install-extensions.sh

# --- 13. Start the shell ---
CMD ["fish"]
