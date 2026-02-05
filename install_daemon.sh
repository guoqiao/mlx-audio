#!/bin/bash

set -ueo pipefail

# Set up macOS LaunchAgent to run mlx-audio server as a service with reliability
domain_target="gui/$(id -u)"
service_id="me.guoqiao.mlx-audio-server"
service_target="${domain_target}/${service_id}"
service_path="${HOME}/Library/LaunchAgents/${service_id}.plist"

log_path="output/mlx_audio_server.log"
mkdir -p $(dirname $log_path)

cat <<EOF > "${service_path}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

    <key>Label</key>
    <string>${service_id}</string>

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
    <string>${log_path}</string>

    <key>StandardErrorPath</key>
    <string>${log_path}</string>

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

# Unload the job if it's already loaded (ignore errors if not loaded)
launchctl bootout ${domain_target} ${service_path} 2>/dev/null || true

# Load (or reload) the job
launchctl bootstrap ${domain_target} ${service_path}

echo "launchd daemon service bootstrapped:"
echo "service path: $service_path"
echo "check log: tail -f $log_path"
echo "restart: launchctl kickstart -k ${service_target}"
echo "show status: launchctl print ${service_target}"

