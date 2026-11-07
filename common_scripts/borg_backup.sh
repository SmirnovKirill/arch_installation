#!/usr/bin/env bash
set -euo pipefail

source ~/arch_installation/variables.sh

src1=$HOME
src2="folder2"
src3="folder3"

if [[ ! -d "$BACKUP_REPO" ]]; then
  echo "Хранилище недоступно: $BACKUP_REPO"
  exit 1
fi

for src in "$src1" "$src2" "$src3"; do
  if [[ ! -d "$src" ]]; then
    echo "Нет исходной папки: $src"
    exit 1
  fi
done

# Исключения относительно первой папки
excludes=()
for path in \
  .android .cache .cert .docker .dotnet .gnupg .gradle \
  .java .jmc .junie .kube .m2 .mozilla .npm .openambit \
  .pki .shl .skaffold .structr .swt .tilt-dev .vim \
  .visualvm .workrave .xmlresolver.org .yarn .zoom \
  .local/share/Trash store Downloads/nosync Desktop
do
  excludes+=(--exclude "$src1/$path")
done

borg create --stats --progress \
  "${excludes[@]}" \
  "$BACKUP_REPO::home-$(date +'%Y-%m-%d_%H-%M')" \
  "$src1" "$src2" "$src3"

borg prune -v --list \
  --keep-daily=7 \
  --keep-weekly=4 \
  --keep-monthly=6 \
  "$BACKUP_REPO"