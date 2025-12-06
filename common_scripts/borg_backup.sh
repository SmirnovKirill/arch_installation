#!/usr/bin/env bash
set -euo pipefail

MOUNT="/run/media/kirill/backupssd"
REPO="$MOUNT/borg_backup_home"

if [ ! -d "$MOUNT" ]; then
  echo "SSD не смонтирован: $MOUNT"
  exit 1
fi

borg create \
  --stats --progress \
  "$REPO"::"home-$(date +'%Y-%m-%d_%H-%M')" \
  --exclude "$HOME/.cache" \
  --exclude "$HOME/.local/share/Trash" \
  --exclude "$HOME/store" \
  --exclude "$HOME/Downloads/nosync" \
  --exclude "$HOME/Desktop" \
  "$HOME"

borg prune -v --list "$REPO" \
  --keep-daily=7 \
  --keep-weekly=4 \
  --keep-monthly=6