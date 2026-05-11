#!/usr/bin/env bash
# Gather everything /review-board needs in one shot.
# Usage: collect_context.sh [pr_number]
# Output is sectioned with `=== HEADER ===` markers for the model to parse.
set -euo pipefail

PR="${1:-}"

# Resolve base branch: origin/HEAD if available, else main, else master.
base="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
if [ -z "$base" ]; then
  if git show-ref --verify --quiet refs/heads/main; then base="main"
  elif git show-ref --verify --quiet refs/heads/master; then base="master"
  else base="main"
  fi
fi

current="$(git rev-parse --abbrev-ref HEAD)"
head_sha="$(git rev-parse --short HEAD)"

echo "=== BRANCH ==="
echo "current=$current"
echo "base=$base"
echo "head=$head_sha"

echo
echo "=== COMMITS ==="
git log "$base..HEAD" --oneline --no-decorate || true

echo
echo "=== STAT ==="
git diff --stat "$base...HEAD" || true

echo
echo "=== FILES ==="
git diff --name-only "$base...HEAD" || true

echo
echo "=== PR ==="
if [ -n "$PR" ]; then
  if command -v gh >/dev/null 2>&1; then
    gh pr view "$PR" --json number,title,body,url,headRefName,baseRefName 2>/dev/null \
      || echo "(gh pr view failed for PR=$PR)"
  else
    echo "(gh not installed; skipping PR fetch)"
  fi
else
  echo "(no PR number provided)"
fi
