#!/usr/bin/env bash
# Uso:
#   ./run.sh              abre o terminal montando o diretório atual em /work/<nome-da-pasta>
#   ./run.sh ~/projetos   abre o terminal montando outro diretório
#   ./run.sh build        (re)constrói a imagem
#   ENGINE=podman ./run.sh   força o motor de container
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="${IMAGE:-fish-container}"
VOLUME="${VOLUME:-fish-container-data}"

if [ -n "${ENGINE:-}" ]; then
  engine="$ENGINE"
elif command -v podman >/dev/null 2>&1; then
  engine=podman
elif command -v docker >/dev/null 2>&1; then
  engine=docker
else
  echo "Nem docker nem podman foram encontrados no PATH." >&2
  exit 1
fi

build() {
  "$engine" build \
    --build-arg USER_UID="$(id -u)" \
    --build-arg USER_GID="$(id -g)" \
    -t "$IMAGE" "$ROOT"
}

if [ "${1:-}" = "build" ]; then
  build
  exit 0
fi

target="$(cd "${1:-$PWD}" && pwd)"
name="$(basename "$target")"

if ! "$engine" image inspect "$IMAGE" >/dev/null 2>&1; then
  build
fi

extra=()
if [ "$engine" = podman ]; then
  # Mantém o seu UID dentro do container (podman rootless)
  extra+=(--userns=keep-id)
fi

exec "$engine" run --rm -it \
  ${extra[@]+"${extra[@]}"} \
  --security-opt label=disable \
  -e TERM \
  -e COLORTERM=truecolor \
  -v "$VOLUME":/home/dev/.local/share \
  -v "$target":"/work/$name" \
  -w "/work/$name" \
  "$IMAGE"
  