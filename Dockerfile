FROM debian:bookworm-slim

# 1. install the system essentials
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
RUN mkdir -p /var/run/sshd && \
    if grep -qE '^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]]' /etc/ssh/sshd_config; then \
      sed -i 's/^[[:space:]]*#\?[[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication yes/' /etc/ssh/sshd_config; \
    else \
      echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config; \
    fi && \
    if grep -qE '^[[:space:]]*#?[[:space:]]*PermitRootLogin[[:space:]]' /etc/ssh/sshd_config; then \
      sed -i 's/^[[:space:]]*#\?[[:space:]]*PermitRootLogin[[:space:]].*/PermitRootLogin no/' /etc/ssh/sshd_config; \
    else \
      echo 'PermitRootLogin no' >> /etc/ssh/sshd_config; \
    fi

# 3. get the virgo user set up w/ sudo access
RUN useradd -m -s /usr/bin/zsh virgo && \
    usermod -aG sudo virgo

# 4. install oh-my-zsh for virgo & set bureau theme
ARG OH_MY_ZSH_REF=349b9e49ced7682e27927ffb34b6522f011f3e74
ARG OH_MY_ZSH_INSTALL_SHA256=21043aec5b791ce4835479dc33ba2f92155946aeafd54604a8c83522627cc803
USER virgo
RUN bash -o pipefail -c 'curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/${OH_MY_ZSH_REF}/tools/install.sh" -o /tmp/install-oh-my-zsh.sh && printf "%s  %s\n" "${OH_MY_ZSH_INSTALL_SHA256}" "/tmp/install-oh-my-zsh.sh" | sha256sum -c - && sh /tmp/install-oh-my-zsh.sh "" --unattended' && \
    rm -f /tmp/install-oh-my-zsh.sh && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bureau"/' ~/.zshrc

# 5. finalize environment
# sshd requires root to bind :22 and fork/setuid into user sessions; leaving final USER as root is intentional
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# expose the std SSH port
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ss -ltn | grep -qE ':(22)( |$)' || exit 1
