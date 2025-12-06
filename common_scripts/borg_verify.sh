#!/usr/bin/env bash
set -euo pipefail

source ~/arch_installation/variables.sh
source ~/arch_installation/functions.sh

usage() {
  cat <<EOF
Использование: $(basename "$0") [РЕЖИМ]

Режимы:
  quick    - стандартная проверка (repo + архивы, БЕЗ verify-data) [по умолчанию]
  full     - ПОЛНАЯ проверка с --verify-data (медленно)

Примеры:
  $(basename "$0")
  $(basename "$0") full
EOF
}

MODE="${1:-quick}"

case "$MODE" in
  quick)
    CHECK_ARGS=()
    DESC="Стандартная проверка репозитория и архивов (без verify-data)"
    ;;
  full)
    CHECK_ARGS=(--verify-data)
    DESC="ПОЛНАЯ проверка с чтением и проверкой всех данных (--verify-data)"
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    log_error "Неизвестный режим: '$MODE'"
    echo
    usage
    exit 1
    ;;
esac

log_info "Режим: $MODE"
log_info "Описание: $DESC"
log_info "Репозиторий: $BACKUP_REPO"
echo

start_ts="$(date +'%Y-%m-%d %H:%M:%S')"
log_info "Старт проверки: $start_ts"
echo

if borg check "${CHECK_ARGS[@]}" "$BACKUP_REPO" --progress; then
  rc=0
else
  rc=$?
fi

echo
end_ts="$(date +'%Y-%m-%d %H:%M:%S')"
log_info "Завершение проверки: $end_ts"
echo

if [ "$rc" -eq 0 ]; then
  log_ok "ЦЕЛОСТНОСТЬ BORG-РЕПОЗИТОРИЯ В ПОРЯДКЕ (режим: $MODE)"
else
  log_error "НАЙДЕНЫ ПРОБЛЕМЫ С РЕПОЗИТОРИЕМ! (режим: $MODE, код возврата: $rc)"
fi

exit "$rc"
