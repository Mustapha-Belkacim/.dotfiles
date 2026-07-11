#!/usr/bin/env bash
#
# Run GitHub Copilot CLI in "YOLO" mode (--allow-all) inside a throwaway
# Docker container. The container can only see the project directory you
# mount, so a bad command or prompt-injection can't touch the rest of your Mac.
#
# Usage:
#   ./run-yolo.sh                 # sandbox the current directory
#   ./run-yolo.sh /path/to/repo   # sandbox a specific directory
#   PERSIST_AUTH=0 ./run-yolo.sh  # fresh login inside the container instead
#
set -euo pipefail

IMAGE="copilot-sandbox"
DOCKERFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/Dockerfile.copilot"

# Directory to expose to Copilot (defaults to cwd).
PROJECT_DIR="${1:-$PWD}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# Build the image if it doesn't exist yet.
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo ">> Building $IMAGE image (first run only)..."
  docker build -f "$DOCKERFILE" -t "$IMAGE" "$(dirname "$DOCKERFILE")"
fi

# By default we reuse your host ~/.copilot login (read-write) so you stay
# logged in between runs. Set PERSIST_AUTH=0 to log in fresh inside the
# container each time instead.
AUTH_MOUNT=()
if [[ "${PERSIST_AUTH:-1}" == "1" ]]; then
  mkdir -p "$HOME/.copilot"
  AUTH_MOUNT=(-v "$HOME/.copilot:/home/dev/.copilot")
fi

# Pass a token through if one is set, so /login isn't needed.
TOKEN_ENV=()
if [[ -n "${GH_TOKEN:-}" ]]; then
  TOKEN_ENV=(-e "GH_TOKEN=$GH_TOKEN")
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  TOKEN_ENV=(-e "GITHUB_TOKEN=$GITHUB_TOKEN")
fi

echo ">> Sandboxing: $PROJECT_DIR"
echo ">> Running Copilot with --allow-all (YOLO) inside container '$IMAGE'"

exec docker run --rm -it \
  -v "$PROJECT_DIR:/work" \
  -e COPILOT_ALLOW_ALL=1 \
  ${TOKEN_ENV[@]+"${TOKEN_ENV[@]}"} \
  ${AUTH_MOUNT[@]+"${AUTH_MOUNT[@]}"} \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 512 \
  "$IMAGE" --allow-all "${@:2}"
