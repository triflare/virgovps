FROM debian:bookworm-slim

# 1. install the system essentials
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    sudo \
    zsh \
    git \
    curl \
    vim \
    man-db \
    procps \
    iproute2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. configure SSH security & access
RUN mkdir /var/run/sshd && \
    sed -i 's/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin[[:space:]].*/PermitRootLogin no/' /etc/ssh/sshd_config

# 3. get the virgo user set up w/ sudo access
RUN useradd -m -s /usr/bin/zsh virgo && \
    usermod -aG sudo virgo

# 4. install oh-my-zsh for virgo & set bureau theme
ARG OH_MY_ZSH_REF=master
ARG OH_MY_ZSH_INSTALL_SHA256=REPLACE_WITH_PINNED_INSTALL_SH_SHA256
USER virgo
RUN curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/${OH_MY_ZSH_REF}/tools/install.sh" -o /tmp/install-oh-my-zsh.sh && \
    printf '%s  %s\n' "${OH_MY_ZSH_INSTALL_SHA256}" "/tmp/install-oh-my-zsh.sh" | sha256sum -c - && \
    sh /tmp/install-oh-my-zsh.sh "" --unattended && \
    rm -f /tmp/install-oh-my-zsh.sh && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bureau"/' ~/.zshrc

# 5. finalize environment
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# expose the std SSH port
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
