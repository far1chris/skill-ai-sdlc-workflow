#!/usr/bin/env bash
set -euo pipefail

ALLOW_EMPTY=0
if [ "${1:-}" = "--allow-empty" ]; then
  ALLOW_EMPTY=1
fi

CHECKS_RUN=0

run_step() {
  local label="$1"
  local cmd="$2"
  if [ -z "$cmd" ]; then
    echo "⏭️  ${label}: [SKIP] not configured"
    return 0
  fi
  echo "▶️  ${label}: ${cmd}"
  eval "$cmd"
  CHECKS_RUN=$((CHECKS_RUN + 1))
}

detect_node_pm() {
  if [ -f "pnpm-lock.yaml" ]; then
    echo "pnpm"
  elif [ -f "yarn.lock" ]; then
    echo "yarn"
  elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
    echo "bun"
  else
    echo "npm"
  fi
}

get_pkg_script() {
  local script_name="$1"
  if command -v node >/dev/null 2>&1 && [ -f "package.json" ]; then
    node -e "
      const fs = require('fs');
      const raw = fs.readFileSync('package.json', 'utf8').replace(/^\uFEFF/, '');
      const pkg = JSON.parse(raw);
      const s = (pkg.scripts && pkg.scripts[process.argv[1]]) || '';
      process.stdout.write(String(s));
    " "$script_name"
  fi
}

TYPECHECK_CMD="${VERIFY_TYPECHECK_CMD:-}"
LINT_CMD="${VERIFY_LINT_CMD:-}"
TEST_CMD="${VERIFY_TEST_CMD:-}"

if [ -f "package.json" ] && [ -z "$TYPECHECK_CMD$LINT_CMD$TEST_CMD" ]; then
  PM="$(detect_node_pm)"

  # 1. Typecheck detection
  for candidate in typecheck type-check check-types; do
    if [ -n "$(get_pkg_script "$candidate")" ]; then
      TYPECHECK_CMD="$PM run $candidate"
      break
    fi
  done
  if [ -z "$TYPECHECK_CMD" ] && [ -f "tsconfig.json" ] && [ -x "./node_modules/.bin/tsc" ]; then
    TYPECHECK_CMD="./node_modules/.bin/tsc --noEmit"
  fi

  # 2. Lint detection
  if [ -n "$(get_pkg_script "lint")" ]; then
    LINT_CMD="$PM run lint"
  fi

  # 3. Test detection (non-interactive CI mode)
  RAW_TEST="$(get_pkg_script "test")"
  if [ -n "$RAW_TEST" ] && ! echo "$RAW_TEST" | grep -q "no test specified"; then
    if echo "$RAW_TEST" | grep -qiE "jest|react-scripts" && ! echo "$RAW_TEST" | grep -qi "watchAll"; then
      if [ "$PM" = "npm" ]; then
        TEST_CMD="CI=true npm test -- --watchAll=false"
      else
        TEST_CMD="CI=true $PM test --watchAll=false"
      fi
    elif echo "$RAW_TEST" | grep -qi "vitest" && ! echo "$RAW_TEST" | grep -qiE "vitest run|--run|--watch=false"; then
      if [ "$PM" = "npm" ]; then
        TEST_CMD="CI=true npm test -- --run"
      else
        TEST_CMD="CI=true $PM test --run"
      fi
    else
      TEST_CMD="CI=true $PM test"
    fi
  fi
elif [ -z "$TYPECHECK_CMD$LINT_CMD$TEST_CMD" ]; then
  if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ] || [ -f "requirements.txt" ]; then
    if command -v mypy >/dev/null 2>&1 && { [ -f "mypy.ini" ] || grep -qs "\[tool\.mypy\]" pyproject.toml 2>/dev/null; }; then
      TYPECHECK_CMD="mypy ."
    fi
    if command -v ruff >/dev/null 2>&1; then
      LINT_CMD="ruff check ."
    elif command -v flake8 >/dev/null 2>&1; then
      LINT_CMD="flake8 ."
    fi
    if command -v pytest >/dev/null 2>&1; then
      TEST_CMD="pytest"
    elif [ -d "tests" ] && command -v python3 >/dev/null 2>&1; then
      TEST_CMD="python3 -m unittest discover -s tests"
    elif [ -d "tests" ] && command -v python >/dev/null 2>&1; then
      TEST_CMD="python -m unittest discover -s tests"
    fi
  elif [ -f "go.mod" ]; then
    TYPECHECK_CMD="go vet ./..."
    if command -v golangci-lint >/dev/null 2>&1; then
      LINT_CMD="golangci-lint run"
    fi
    TEST_CMD="go test ./..."
  elif [ -f "Cargo.toml" ]; then
    TYPECHECK_CMD="cargo check"
    if cargo clippy --version >/dev/null 2>&1; then
      LINT_CMD="cargo clippy -- -D warnings"
    fi
    TEST_CMD="cargo test"
  fi
fi

echo "========================================"
echo "🛡️  AI-SDLC Verification Gate"
echo "========================================"

run_step "🔍 [1/3] Type Check" "$TYPECHECK_CMD"
run_step "🧹 [2/3] Linter" "$LINT_CMD"
run_step "🧪 [3/3] Tests" "$TEST_CMD"

if [ "$CHECKS_RUN" -eq 0 ] && [ "$ALLOW_EMPTY" -ne 1 ]; then
  echo "❌ ERROR: No typecheck, lint, or test runner was detected (0 checks ran)."
  echo "Configure scripts in package.json (typecheck/lint/test) or set VERIFY_TYPECHECK_CMD / VERIFY_LINT_CMD / VERIFY_TEST_CMD."
  exit 2
fi

echo "✅ ALL CHECKS PASSED! (${CHECKS_RUN} check(s) succeeded)"
