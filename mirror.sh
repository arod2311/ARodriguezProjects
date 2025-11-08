#!/usr/bin/env bash
set -euo pipefail

if ! command -v git-filter-repo >/dev/null 2>&1; then
  echo "Install git-filter-repo first: pipx install git-filter-repo"
  exit 1
fi

SRC="${1:?Usage: mirror.sh <source_repo_path> <public_git_ssh_url> [subdir_to_keep_or_dot]}"
DST_REMOTE="${2:?public ssh url, e.g., git@github-aro:arod2311/sousan-portfolio.git}"
KEEP_PATH="${3:-.}"  # "." means keep whole repo; otherwise a subfolder like "app"

# Directory of this script (so we can find the redactions file reliably)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WORK="$(mktemp -d)"
cp -R "$SRC" "$WORK/src"
cd "$WORK/src"

# Fresh, local-only git repo so we never touch original remotes/history
if [ -d .git ]; then rm -rf .git; fi
git init
git add .
git commit -m "temp import for filtering"

# Optionally keep only a subdirectory (e.g., 'app' for stagealliance)
if [ "$KEEP_PATH" != "." ]; then
  git filter-repo --path "$KEEP_PATH/" --path-rename "$KEEP_PATH/":""
fi

# Apply removals & replacements
git filter-repo \
  --invert-paths --paths-from-file <(grep '^path:' "$SCRIPT_DIR/.portfolio-redactions.txt" | cut -d: -f2) \
  --replace-text "$SCRIPT_DIR/.portfolio-redactions.txt" \
  --force

# Push to public mirror
git remote add origin "$DST_REMOTE"
git branch -M main
git push -u origin main --force

echo "✅ Mirror complete → $DST_REMOTE"
echo "Temporary work dir: $WORK  (will not auto-delete)"
