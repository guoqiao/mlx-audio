#!/bin/bash

set -ueo pipefail

audio=${1:-$HOME/Music/audio.mp3}
model=${2:-"mlx-community/glm-asr-nano-2512-8bit"}

port=${MLX_AUDIO_SERVER_PORT:-8899}
/usr/bin/time -p curl -sS -X POST http://localhost:${port}/v1/audio/transcriptions \
  -F "format=txt" \
  -F "file=@${audio}" \
  -F "model=${model}" | jq

