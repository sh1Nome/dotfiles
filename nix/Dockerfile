FROM debian:latest

# 必要なパッケージのインストール（git追加）
RUN apt-get update && \
	apt-get install -y sudo curl xz-utils git && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# ユーザー・グループ作成
ARG USERNAME=sh1nome
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd -g ${USER_GID} ${USERNAME} && \
	useradd -m -u ${USER_UID} -g ${USER_GID} -m ${USERNAME} && \
	usermod -aG sudo ${USERNAME}

# sudoパスワードなし設定
RUN sed -i 's|^%sudo\s\+ALL=(ALL:ALL) ALL|%sudo   ALL=(ALL:ALL) NOPASSWD: ALL|' /etc/sudoers

# Nixインストール（非デーモン）
USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon


# Nixパスを直接通す（.bashrcに追記）
RUN echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> /home/${USERNAME}/.bashrc

# bashをデフォルトシェルに
SHELL ["/bin/bash", "-c"]

# デフォルトでbash起動
CMD ["bash"]
