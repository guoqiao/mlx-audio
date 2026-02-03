tool:
    # install as cli, not pkg
	uv tool install --force --prerelease=allow -e ".[server]"

pip:
    # install as pkg
	uv pip install -e ".[server]"

# use env var to override
MLX_AUDIO_SERVER_PORT ?= 8899

server: pip
	@echo "start mlx-audio server on port ${MLX_AUDIO_SERVER_PORT}"
	touch .env
	uv run --env-file .env -m mlx_audio.server --host 0.0.0.0 --port ${MLX_AUDIO_SERVER_PORT}

daemon: pip
	@echo "install plist to run mlx-audio server as a launchd daemon"
	bash install_daemon.sh

tail:
	@echo "tail logs"
	# in plist, logs are written to output/
	tail -n 50 -f output/*.log

models:
	@echo "list available models"
	curl -sS -X GET http://localhost:${MLX_AUDIO_SERVER_PORT}/v1/models | jq

stt:
	bash -xue run_stt.sh

tts:
	bash -xue run_tts.sh
