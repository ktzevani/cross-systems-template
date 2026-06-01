#!/usr/bin/env bash
set -e
echo "Starting container…"
# Ensure GPU is visible
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "ERROR: No GPU detected (nvidia-smi missing)."
    exit 1
fi
# Ensure Python dependencies are installed
MARKER="/opt/project/.venv/linux"
if [ ! -d "$MARKER" ]; then
    uv venv .venv/linux --python /venv/bin/python --system-site-packages
    . .venv/linux/bin/activate
    uv sync --group dev
    echo "Local Python environment initialized"
fi
exec "$@"