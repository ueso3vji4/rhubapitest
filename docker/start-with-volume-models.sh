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

echo "ComfyUI directory: $COMFY_DIR"

mkdir -p "$COMFY_DIR/models"
MODEL_SOURCE=""
for d in /workspace/ComfyUI/models /runpod-volume/ComfyUI/models; do
  if [ -d "$d" ]; then
    MODEL_SOURCE="$d"
    break
  fi
done

if [ -n "$MODEL_SOURCE" ]; then
  echo "Linking models from $MODEL_SOURCE"
  for item in "$MODEL_SOURCE"/*; do
    [ -e "$item" ] || continue
    ln -sfn "$item" "$COMFY_DIR/models/$(basename "$item")"
  done
else
  echo "No network volume model folder found at /workspace/ComfyUI/models or /runpod-volume/ComfyUI/models"
fi

echo "Custom nodes available:"
ls -la "$COMFY_DIR/custom_nodes" || true

echo "Models available:"
find "$COMFY_DIR/models" -maxdepth 2 -type f | sed "s#^$COMFY_DIR/models/##" | head -200 || true

echo "Required workflow assets:"
if [ -e "$COMFY_DIR/models/diffusion_models/flux-2-klein-9b-fp8.safetensors" ]; then
  echo "  ok: diffusion_models/flux-2-klein-9b-fp8.safetensors"
elif [ -e "$COMFY_DIR/models/unet/flux-2-klein-9b-fp8.safetensors" ]; then
  echo "  ok: unet/flux-2-klein-9b-fp8.safetensors"
else
  echo "  missing: flux-2-klein-9b-fp8.safetensors in diffusion_models/ or unet/"
fi

if [ -e "$COMFY_DIR/models/clip/qwen_3_8b_fp8mixed.safetensors" ]; then
  echo "  ok: clip/qwen_3_8b_fp8mixed.safetensors"
elif [ -e "$COMFY_DIR/models/text_encoders/qwen_3_8b_fp8mixed.safetensors" ]; then
  echo "  ok: text_encoders/qwen_3_8b_fp8mixed.safetensors"
else
  echo "  missing: qwen_3_8b_fp8mixed.safetensors in clip/ or text_encoders/"
fi

if [ -e "$COMFY_DIR/models/vae/flux2-vae.safetensors" ]; then
  echo "  ok: vae/flux2-vae.safetensors"
else
  echo "  missing: vae/flux2-vae.safetensors"
fi

echo "Required custom node directories:"
for required in \
  "ComfyUI_LayerStyle" \
  "ComfyUI_LayerStyle_Advance" \
  "ComfyUI_Comfyroll_CustomNodes" \
  "ComfyUI-KJNodes" \
  "Comfyui_TTP_Toolset" \
  "ComfyUI-Easy-Use" \
  "ComfyUI-SeedVR2_VideoUpscaler" \
  "ComfyUI-Impact-Pack" \
  "ComfyUI-Impact-Subpack" \
  "ComfyUI-QwenVL"; do
  if [ -d "$COMFY_DIR/custom_nodes/$required" ]; then
    echo "  ok: $required"
  else
    echo "  missing: $required"
  fi
done

exec /start.sh
