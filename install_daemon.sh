#!/bin/bash

set -ueo pipefail

# Set up macOS LaunchAgent to run mlx-audio server as a service with reliability
SERVICE_NAME="me.guoqiao.mlx-audio-server"
PLIST_PATH="$HOME/Library/LaunchAgents/${SERVICE_NAME}.plist"
LOG_PATH="output/mlx_audio_server.log"
mkdir -p $(dirname $LOG_PATH)

cat <<EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

    <key>Label</key>
    <string>${SERVICE_NAME}</string>

    <key>WorkingDirectory</key>
    <string>$(pwd)</string>

    <key>ProgramArguments</key>
    <array>
        <string>make</string>
        <string>server</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>${LOG_PATH}</string>

    <key>StandardErrorPath</key>
    <string>${LOG_PATH}</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$PATH</string>
        <key>MLX_AUDIO_SERVER_PORT</key>
        <string>8899</string>
    </dict>

</dict>
</plist>
EOF

# cat "$PLIST_PATH"

# Unload the job if it's already loaded (ignore errors if not loaded)
launchctl bootout "gui/$(id -u)" "$PLIST_PATH" 2>/dev/null || true

# Load (or reload) the job
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"

# Optionally (re-)kickstart the job to ensure it's running the latest version
# launchctl kickstart -k "gui/$(id -u)/${SERVICE_NAME}"

# Show current status
# launchctl print "gui/$(id -u)/${SERVICE_NAME}"

echo "daemon service bootstrapped:"
echo "plist file: $PLIST_PATH"
echo "check log: tail -f $LOG_PATH"
echo "restart: launchctl kickstart -k gui/$(id -u)/${SERVICE_NAME}"
