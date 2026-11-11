#!/usr/bin/env bash
set -euo pipefail

FEATURE_SLUG=""
COMMIT_TYPE="feat"
DRY_RUN=0
DO_PUSH=0
DO_PR=0
ALLOW_NO_SPEC=0
FORCE=0

usage() {
  cat <<'EOF'
Usage: ship-pr.sh <feature-slug> [options]

Options:
  --type <feat|fix|refactor|chore|docs>  Conventional commit type (default: feat)
  --dry-run                              Preview actions without mutating git
  --push                                 Push feature/<slug> to origin after commit
  --pr                                   Push and open GitHub PR via gh CLI
  --allow-no-spec                        Skip specs/<slug>/ gate artifact checks
  --force                                Allow shipping even if tasks.md has unchecked items
  -h, --help                             Show help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --type)
      COMMIT_TYPE="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --push)
      DO_PUSH=1
      shift
      ;;
    --pr)
      DO_PUSH=1
      DO_PR=1
      shift
      ;;
    --allow-no-spec)
      ALLOW_NO_SPEC=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option '$1'" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -z "$FEATURE_SLUG" ]; then
        FEATURE_SLUG="$1"
        shift
      else
        echo "Error: Unexpected argument '$1'" >&2
        exit 1
      fi
      ;;
  esac
done

if [ -z "$FEATURE_SLUG" ]; then
  echo "Error: <feature-slug> is required (e.g. discount-coupons)" >&2
  usage >&2
  exit 1
fi

if ! echo "$FEATURE_SLUG" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
  echo "Error: Invalid feature-slug '$FEATURE_SLUG'. Use lowercase letters, numbers, and hyphens only." >&2
  exit 1
fi

case "$COMMIT_TYPE" in
  feat|fix|refactor|chore|docs|test) ;;
  *)
    echo "Error: Invalid --type '$COMMIT_TYPE'. Allowed: feat, fix, refactor, chore, docs, test" >&2
    exit 1
    ;;
esac

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Current directory is not inside a git repository." >&2
  exit 1
fi

if [ -n "$(git ls-files --unmerged)" ]; then
  echo "Error: Unresolved merge conflicts detected. Resolve them before running ship-pr." >&2
  exit 1
fi

SPEC_DIR="specs/${FEATURE_SLUG}"
if [ "$ALLOW_NO_SPEC" -ne 1 ]; then
  if [ ! -f "${SPEC_DIR}/spec.md" ] || [ ! -f "${SPEC_DIR}/walkthrough.md" ]; then
    echo "Error: Missing Gate artifacts (${SPEC_DIR}/spec.md and/or ${SPEC_DIR}/walkthrough.md)." >&2
    echo "Complete Stage 1 (SPEC) and Stage 4 (REVIEW) before shipping, or pass --allow-no-spec if specs are excluded." >&2
    exit 1
  fi
  if [ "$FORCE" -ne 1 ] && [ -f "${SPEC_DIR}/tasks.md" ] && grep -qE '^\s*-\s*\[ \]' "${SPEC_DIR}/tasks.md"; then
    echo "Error: ${SPEC_DIR}/tasks.md still has unchecked '- [ ]' tasks." >&2
    echo "Complete and check off all tasks first (or pass --force to override)." >&2
    exit 1
  fi
fi

# Guard against staging secret/credential files (POSIX ERE compatible across Linux/macOS/Git Bash)
SENSITIVE_HITS="$(
  git status --porcelain \
    | sed -E 's/^...//; s/^"//; s/"$//; s/.* -> //' \
    | grep -E '(^|/)\.env($|\.)|\.(pem|key|p12|pfx)$|(^|/)id_rsa|credentials.*\.json$' \
    | grep -vE '(^|/)\.env\.(example|sample|template)$' \
    || true
)"
if [ -n "$SENSITIVE_HITS" ]; then
  echo "Error: Potential secret/credential files detected in working tree:" >&2
  echo "$SENSITIVE_HITS" >&2
  echo "Remove or add them to .gitignore before committing." >&2
  exit 1
fi

BRANCH_NAME="feature/${FEATURE_SLUG}"
COMMIT_MSG="${COMMIT_TYPE}(${FEATURE_SLUG}): implement verified changes per spec"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[DRY-RUN] Target branch : ${BRANCH_NAME}"
  echo "[DRY-RUN] Commit message: ${COMMIT_MSG}"
  echo "[DRY-RUN] Pending workspace changes:"
  git status --short
  exit 0
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "Error: Working tree is clean; nothing to commit." >&2
  exit 1
fi

CURRENT_BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo "")"
if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
  if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    git checkout "$BRANCH_NAME"
  else
    git checkout -b "$BRANCH_NAME"
  fi
fi

git add -A
if git diff --cached --quiet; then
  echo "Error: Nothing staged for commit after git add -A." >&2
  exit 1
fi

echo "📦 Staged changes summary:"
git diff --cached --stat

git commit -m "$COMMIT_MSG"
echo "🚀 Committed to branch: ${BRANCH_NAME}"

if [ "$DO_PUSH" -eq 1 ]; then
  git push -u origin "$BRANCH_NAME"
  if [ "$DO_PR" -eq 1 ]; then
    if command -v gh >/dev/null 2>&1; then
      if [ -f "${SPEC_DIR}/walkthrough.md" ]; then
        gh pr create --title "$COMMIT_MSG" --body-file "${SPEC_DIR}/walkthrough.md"
      else
        gh pr create --title "$COMMIT_MSG" --fill
      fi
    else
      echo "⚠️  'gh' CLI not found. Push succeeded; open the PR from your Git host UI."
    fi
  fi
else
  echo ""
  echo "Next commands to push / open Pull Request:"
  echo "  git push -u origin ${BRANCH_NAME}"
  if [ -f "${SPEC_DIR}/walkthrough.md" ]; then
    echo "  gh pr create --title \"${COMMIT_MSG}\" --body-file \"${SPEC_DIR}/walkthrough.md\""
  else
    echo "  gh pr create --title \"${COMMIT_MSG}\" --fill"
  fi
fi
