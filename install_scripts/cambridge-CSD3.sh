#!/usr/bin/env bash
# Set up MatFlow on Cambridge CSD3.
#
# Requires uv. Usage (override any variable as needed):
#   DREAM3D_SRC=/path/to/DREAM3D-6.5.171-Linux-x86_64.tar.gz \
#   DAMASK_SIF_SRC=/path/to/damask-grid_3.1.0-ib.sif \
#   ./cambridge-CSD3.sh

set -euo pipefail

# --- Configuration -----------------------------------------------------------
MATFLOW_VERSION="${MATFLOW_VERSION:-0.6.0a0}"
PYTHON_VERSION="${PYTHON_VERSION:-3.13}"
VENV_DIR="${VENV_DIR:-$HOME/matflow-venv}"

# Set to 1 to pause after creating the venv, before it is activated:
PAUSE_AFTER_VENV="${PAUSE_AFTER_VENV:-0}"

# Where the software files are copied to (created if it doesn't exist):
SOFTWARE_DIR="${SOFTWARE_DIR:-$HOME/software}"

# Source locations of the software to copy:
DREAM3D_SRC="${DREAM3D_SRC:?Set DREAM3D_SRC to the DREAM3D .tar.gz archive}"
DAMASK_SIF_SRC="${DAMASK_SIF_SRC:?Set DAMASK_SIF_SRC to the DAMASK grid SIF file}"

# --- Derived paths -----------------------------------------------------------
DREAM3D_ARCHIVE="$SOFTWARE_DIR/$(basename "$DREAM3D_SRC")"
# Assumes the archive's top-level directory matches the archive name:
DREAM3D_DIR="$SOFTWARE_DIR/$(basename "$DREAM3D_SRC" .tar.gz)"
DREAM3D_RUNNER="$DREAM3D_DIR/bin/PipelineRunner"
DAMASK_SIF="$SOFTWARE_DIR/$(basename "$DAMASK_SIF_SRC")"

# --- 1. Python environment ---------------------------------------------------
echo "Creating Python $PYTHON_VERSION venv at $VENV_DIR..."
uv venv --allow-existing --python "$PYTHON_VERSION" "$VENV_DIR"
uv pip install --python "$VENV_DIR/bin/python" --prerelease=allow \
    "matflow==$MATFLOW_VERSION" damask damask-parse mtex

if [[ "$PAUSE_AFTER_VENV" == "1" ]]; then
    echo "Paused: edit $VENV_DIR/bin/activate if needed (e.g. export MATFLOW_CONFIG_DIR)."
    read -r -p "Press Enter to continue..." < /dev/tty
fi

set +u
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
set -u

# --- 2. MatFlow configuration ------------------------------------------------
echo "Importing CSD3 MatFlow configuration..."
matflow config import --remote cambridge-CSD3.yaml

# --- 3. Copy software files --------------------------------------------------
echo "Copying software into $SOFTWARE_DIR..."
mkdir -p "$SOFTWARE_DIR"
cp "$DREAM3D_SRC" "$DREAM3D_ARCHIVE"
tar -xzf "$DREAM3D_ARCHIVE" -C "$SOFTWARE_DIR"
cp "$DAMASK_SIF_SRC" "$DAMASK_SIF"

[[ -x "$DREAM3D_RUNNER" ]] || { echo "Error: $DREAM3D_RUNNER not found or not executable" >&2; exit 1; }
[[ -f "$DAMASK_SIF" ]] || { echo "Error: $DAMASK_SIF not found" >&2; exit 1; }

# --- 4. MatFlow environments -------------------------------------------------
echo "Setting up MatFlow environments..."
matflow env setup python-all --use-current
matflow env setup dream3d --use-current -p "$DREAM3D_RUNNER"
matflow env import --remote environments/cambridge-CSD3-damask.yaml \
    --name damask_env \
    --var sif_path "$DAMASK_SIF" \
    --replace

echo "Done. Activate the environment with: source $VENV_DIR/bin/activate"
