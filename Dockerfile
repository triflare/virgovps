FROM debian:bookworm-slim

# set to non-interactive to keep build clean
ENV DEBIAN_FRONTEND=noninteractive

# 1. install the system essentials
RUN apt-get update && apt-get install -y \
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

# 2. configure SSSH security & access
RUN mkdir /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# 3. get the virgo user set up w/ sudo access
RUN useradd -m -s /usr/bin/zsh virgo && \
    usermod -aG sudo virgo

# 4. install oh-my-zsh for virgo & set bureau theme
USER virgo
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bureau"/' ~/.zshrc

# 5. finalize environment
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# expose the std SSH port
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
