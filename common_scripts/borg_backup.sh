#!/usr/bin/env bash
set -euo pipefail

source ~/arch_installation/variables.sh

if [ ! -d "$BACKUP_DEVICE_PATH" ]; then
  echo "SSD не смонтирован: $BACKUP_DEVICE_PATH"
  exit 1
fi

borg create \
  --stats --progress \
  "$BACKUP_REPO"::"home-$(date +'%Y-%m-%d_%H-%M')" \
  --exclude "$HOME/.cache" \
  --exclude "$HOME/.local/share/Trash" \
  --exclude "$HOME/store" \
  --exclude "$HOME/Downloads/nosync" \
  --exclude "$HOME/Desktop" \
  "$HOME"

borg prune -v --list "$BACKUP_REPO" \
  --keep-daily=7 \
  --keep-weekly=4 \
  --keep-monthly=6