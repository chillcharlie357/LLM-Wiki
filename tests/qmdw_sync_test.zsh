#!/bin/zsh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/qmdw-sync-test.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT

FAKE_BIN="$TEST_DIR/bin"
mkdir -p "$FAKE_BIN"

cat > "$FAKE_BIN/qmd" <<'EOF'
#!/bin/zsh
print -r -- "$*" >> "$QMDW_TEST_CALL_LOG"

if [[ "$1 $2" == "collection show" ]]; then
  if [[ "${QMDW_TEST_SHOW_ERROR:-}" == "$3" ]]; then
    print -u2 -- "database locked while reading $3"
    exit 2
  fi
  if [[ ",${QMDW_TEST_EXISTING:-}," == *",$3,"* ]]; then
    exit 0
  fi
  print -u2 -- "Collection not found: $3"
  exit 1
fi

if [[ "${QMDW_TEST_FAIL_COMMAND:-}" == "$1 $2" || "${QMDW_TEST_FAIL_COMMAND:-}" == "$1" ]]; then
  print -u2 -- "forced failure: $*"
  exit 3
fi
EOF
chmod +x "$FAKE_BIN/qmd"

assert_calls() {
  local case_name="$1"
  local expected="$2"
  local actual="$(<"$QMDW_TEST_CALL_LOG")"

  if [[ "$actual" != "$expected" ]]; then
    print -u2 -- "FAIL: $case_name"
    print -u2 -- "Expected:"
    print -u2 -- "$expected"
    print -u2 -- "Actual:"
    print -u2 -- "$actual"
    exit 1
  fi
}

run_sync() {
  PATH="$FAKE_BIN:$PATH" QMDW_TEST_CALL_LOG="$QMDW_TEST_CALL_LOG" \
    QMDW_TEST_EXISTING="${QMDW_TEST_EXISTING:-}" \
    QMDW_TEST_SHOW_ERROR="${QMDW_TEST_SHOW_ERROR:-}" \
    QMDW_TEST_FAIL_COMMAND="${QMDW_TEST_FAIL_COMMAND:-}" \
    "$REPO_ROOT/qmdw" sync
}

QMDW_TEST_CALL_LOG="$TEST_DIR/fresh.log"
QMDW_TEST_EXISTING=""
run_sync
assert_calls "fresh sync initializes both collections" "$(cat <<EOF
collection show wiki
collection add $REPO_ROOT/wiki --name wiki
collection show raw
collection add $REPO_ROOT/raw --name raw
update
embed
EOF
)"

QMDW_TEST_CALL_LOG="$TEST_DIR/repeated.log"
QMDW_TEST_EXISTING="wiki,raw"
run_sync
assert_calls "repeated sync is idempotent" "$(cat <<'EOF'
collection show wiki
collection show raw
update
embed
EOF
)"

QMDW_TEST_CALL_LOG="$TEST_DIR/partial.log"
QMDW_TEST_EXISTING="wiki"
run_sync
assert_calls "partial sync initializes only the missing collection" "$(cat <<EOF
collection show wiki
collection show raw
collection add $REPO_ROOT/raw --name raw
update
embed
EOF
)"

QMDW_TEST_CALL_LOG="$TEST_DIR/show-error.log"
QMDW_TEST_EXISTING="raw"
QMDW_TEST_SHOW_ERROR="wiki"
if run_sync >"$TEST_DIR/show-error.out" 2>"$TEST_DIR/show-error.err"; then
  print -u2 -- "FAIL: collection inspection errors must stop sync"
  exit 1
fi
rg -q "database locked while reading wiki" "$TEST_DIR/show-error.err"
assert_calls "collection inspection error is not treated as absence" "collection show wiki"

for failure in "collection add" update embed; do
  QMDW_TEST_CALL_LOG="$TEST_DIR/failure-${failure// /-}.log"
  QMDW_TEST_EXISTING="$([[ "$failure" == "collection add" ]] && print raw || print wiki,raw)"
  QMDW_TEST_SHOW_ERROR=""
  QMDW_TEST_FAIL_COMMAND="$failure"
  if run_sync >/dev/null 2>&1; then
    print -u2 -- "FAIL: $failure failure must propagate"
    exit 1
  fi
done

print -- "PASS: qmdw sync initialization, idempotency, and failures"
