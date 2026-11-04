# Nome totalmente qualificado para funcionar igual no Docker e no Podman.
# Debian 13 (trixie) porque o fzf de lá já tem o suporte ao fish (fzf --fish).
FROM docker.io/library/debian:trixie-slim

ARG USER_UID=1000
ARG USER_GID=1000

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git less \
      fish bat eza zoxide fzf fd-find silversearcher-ag \
 && ln -s /usr/bin/batcat /usr/local/bin/bat \
 && ln -s /usr/bin/fdfind /usr/local/bin/fd \
 && curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${USER_GID}" dev \
 && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /usr/bin/fish dev \
 && mkdir -p /work /home/dev/.config/fish /home/dev/.local/share \
 && chown -R dev:dev /work /home/dev

COPY --chown=dev:dev config/fish/config.fish /home/dev/.config/fish/config.fish
COPY --chown=dev:dev config/starship.toml /home/dev/.config/starship.toml

USER dev
WORKDIR /work
CMD ["fish"]
