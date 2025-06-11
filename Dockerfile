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
ENV USER_UID=1000
ENV USER_GID=1000

# --- Copy dependency definitions ---
COPY system-packages.txt /tmp/system-packages.txt

# --- Install system packages ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    mkdir -p $PIP_CACHE_DIR $RENV_PATHS_CACHE && \
    # Install all packages from system-packages.txt
    apt-get update -qq && \
    grep -v '^#' /tmp/system-packages.txt | grep -v '^$' | xargs apt-get install -y --no-install-recommends && \
    rm -f /tmp/system-packages.txt

# --- Configure locales ---
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# --- Install R from CRAN ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    r-base=4.5.* \
    r-base-dev=4.5.*

# --- Install Fish Shell ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    add-apt-repository ppa:fish-shell/release-4 -y && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    fish

# --- Create non-root user ---
RUN existing_user=$(getent passwd ${USER_UID} | cut -d: -f1) && \
    if [ -n "$existing_user" ]; then \
        if [ "$existing_user" != "${USER_NAME}" ]; then \
            usermod -l ${USER_NAME} -d /home/${USER_NAME} -m $existing_user 2>/dev/null || true; \
            groupmod -n ${USER_NAME} $existing_user 2>/dev/null || true; \
        fi; \
    else \
        groupadd --gid ${USER_GID} ${USER_NAME} 2>/dev/null || true; \
        useradd --uid ${USER_UID} --gid ${USER_GID} --shell /usr/bin/fish --create-home ${USER_NAME}; \
    fi && \
    usermod --shell /usr/bin/fish ${USER_NAME} 2>/dev/null || true && \
    usermod -aG sudo ${USER_NAME} 2>/dev/null || true && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME} && \
    chmod 440 /etc/sudoers.d/${USER_NAME} && \
    mkdir -p /home/${USER_NAME}/project && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME} 2>/dev/null || true && \
    chown -R ${USER_UID}:${USER_GID} ${RENV_PATHS_CACHE} 2>/dev/null || true

# --- Install Starship prompt ---
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# --- Install VS Code (multiarch compatible) ---
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    rm -f packages.microsoft.gpg && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    code

# Switch to non-root user
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/project

# --- Install Python packages as user ---
RUN --mount=type=cache,target=/home/${USER_NAME}/.cache/pip \
    pip3 install --user --break-system-packages radian

# --- Setup R environment as user ---
RUN mkdir -p /home/${USER_NAME}/R/library && \
    echo 'R_LIBS_USER="/home/${USER_NAME}/R/library"' > /home/${USER_NAME}/.Renviron && \
    R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'), lib = '/home/${USER_NAME}/R/library')"

# --- Configure R profile ---
COPY --chown=${USER_NAME}:${USER_NAME} .Rprofile /home/${USER_NAME}/.Rprofile

# --- Configure Starship prompt and Fish shell ---
COPY --chown=${USER_NAME}:${USER_NAME} config.fish /tmp/config.fish
RUN mkdir -p /home/${USER_NAME}/.config && \
    starship preset no-nerd-font -o /home/${USER_NAME}/.config/starship.toml && \
    mkdir -p /home/${USER_NAME}/.config/fish && \
    cp /tmp/config.fish /home/${USER_NAME}/.config/fish/config.fish && \
    rm /tmp/config.fish

# --- Start the shell ---
CMD ["fish"]
