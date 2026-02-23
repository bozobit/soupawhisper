#!/bin/bash
# SoupaWhisper launcher — sets CUDA library paths from pip-installed nvidia packages
VENV="/home/rich/Dev/soupawhisper/.venv"
NVIDIA_LIBS="$VENV/lib/python3.12/site-packages/nvidia"
export LD_LIBRARY_PATH="$NVIDIA_LIBS/cublas/lib:$NVIDIA_LIBS/cudnn/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$VENV/bin/python" /home/rich/Dev/soupawhisper/dictate.py "$@"
