#!/usr/bin/env bash
set -euo pipefail

COMFY_DIR=""
for d in /comfyui /ComfyUI /workspace/ComfyUI /app/ComfyUI; do
  if [ -d "$d" ]; then
    COMFY_DIR="$d"
    break
  fi
done

if [ -z "$COMFY_DIR" ]; then
  echo "Could not find ComfyUI directory" >&2
  exit 1
fi

echo "Installing custom nodes into $COMFY_DIR/custom_nodes"
mkdir -p "$COMFY_DIR/custom_nodes"

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends git
  rm -rf /var/lib/apt/lists/*
fi

while IFS= read -r repo; do
  [ -z "$repo" ] && continue
  name="$(basename "$repo" .git)"
  target="$COMFY_DIR/custom_nodes/$name"
  if [ ! -d "$target/.git" ]; then
    git clone --depth 1 "$repo" "$target"
  fi
  if [ -f "$target/requirements.txt" ]; then
    python -m pip install --no-cache-dir -r "$target/requirements.txt"
  fi
  if [ -f "$target/install.py" ]; then
    (cd "$target" && python install.py)
  fi
done < /opt/runpod/custom-nodes.txt

echo "Baked custom nodes:"
ls -la "$COMFY_DIR/custom_nodes"
