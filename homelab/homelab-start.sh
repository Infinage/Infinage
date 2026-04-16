#!/bin/bash

# crontab -e
# @reboot /home/kael/infinage/homelab/homelab-start.sh

# Give system time to settle
sleep 10

COMPOSE_FILE="/home/kael/infinage/homelab/docker-compose.yaml"
LOG_FILE="/home/kael/homelab_startup.log"

# Supress the external provider message
export PODMAN_COMPOSE_WARNING_LOGS=0

{
    echo "--- Startup initiated at $(date) ---"

    echo "Cleaning up old state..."
    /usr/bin/podman compose -f "$COMPOSE_FILE" down >/dev/null 2>&1

    echo "Launching containers..."
    /usr/bin/podman compose -f "$COMPOSE_FILE" up -d

    echo "Current Status:"
    /usr/bin/podman compose -f "$COMPOSE_FILE" ps

    echo "--- Startup finished at $(date) ---"
    echo ""
} >> "$LOG_FILE" 2>&1
