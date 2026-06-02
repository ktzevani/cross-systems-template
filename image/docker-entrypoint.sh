#!/usr/bin/env bash
set -e
echo "Starting container…"
# Ensure GPU is visible
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "ERROR: No GPU detected (nvidia-smi missing)."
    exit 1
fi
# Use the Python environment baked into the image.
export UV_PROJECT_ENVIRONMENT="/venv"
uv sync --group dev --inexact
echo "Python environment configured and active: /venv"
exec "$@"
