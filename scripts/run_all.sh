#!/usr/bin/env bash
# Пересоздаёт базу airport с нуля и прогоняет все лабы по порядку (1 → 7).
# После этого база готова к лабе 8.
#
# Запуск через Docker (из корня репозитория):
#   docker compose up -d
#   docker exec -it airport-db bash /labs/scripts/run_all.sh
#
# Или с локальным Postgres:
#   PGHOST=localhost PGUSER=postgres PGPASSWORD=... bash scripts/run_all.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB="${DB:-airport}"
# По умолчанию пользователь postgres; на Mac (Homebrew) суперпользователь = твой логин macOS
if [ -z "${PGUSER:-}" ]; then
  if psql -X -U postgres -d postgres -c "" >/dev/null 2>&1; then export PGUSER=postgres; else export PGUSER="$(whoami)"; fi
fi
PSQL="psql -v ON_ERROR_STOP=1 -q -X"

echo ">> Recreating database $DB"
$PSQL -d postgres -c "DROP DATABASE IF EXISTS $DB WITH (FORCE);"
$PSQL -d postgres -c "CREATE DATABASE $DB;"

run() {
  echo ">> $1"
  $PSQL -d "$DB" -f "$ROOT/$1" > /dev/null
}

# В лабах 5 и 7 есть специальные запросы, которые ДОЛЖНЫ упасть с ошибкой
# (проверка ограничений). Для них не останавливаемся на ошибке.
run_with_expected_errors() {
  echo ">> $1 (expected errors below are OK)"
  psql -q -X -v ON_ERROR_STOP=0 -d "$DB" -f "$ROOT/$1" > /dev/null 2> >(grep ERROR >&2)
}

run lab02-normalization-ddl/ddl.sql
run lab02-normalization-ddl/normalization.sql
run lab03-dml/task00_prepare.sql
run lab03-dml/task01_seed.sql
run lab03-dml/lab03.sql
run lab04-queries/lab04.sql
run_with_expected_errors lab05-constraints/lab05.sql
run lab06-joins/lab06.sql
run lab07-indexes/task00_bulk_data.sql
run_with_expected_errors lab07-indexes/lab07.sql
sleep 1

echo ">> Done. Database '$DB' is ready for Lab 8."
