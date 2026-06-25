#!/usr/bin/env bash
# One-time: create jbearak/homebrew-raven and seed it from this scaffold with
# the REAL Apple Silicon checksum for an existing raven release. Safe to re-run.
#
#   ./bootstrap.sh [version]      # default: 0.11.2
#
# Requires: gh (authenticated), git, perl. Run from this directory.
set -euo pipefail

VERSION="${1:-0.11.2}"; VERSION="${VERSION#v}"
OWNER=jbearak
TAP=homebrew-raven
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

tmp="$(mktemp -d)"
echo "==> Downloading raven v$VERSION macOS arm64 artifact..."
gh release download "v$VERSION" -R "$OWNER/raven" \
  --pattern 'raven-macos-arm64.zip' \
  --dir "$tmp"

echo "==> Filling formula with real checksum..."
bin/update-formula.sh "$VERSION" "$tmp/raven-macos-arm64.zip"

if ! gh repo view "$OWNER/$TAP" >/dev/null 2>&1; then
  echo "==> Creating $OWNER/$TAP..."
  gh repo create "$OWNER/$TAP" --public \
    --description "Homebrew tap for raven, a static analyzer for R (jbearak/raven)"
fi

echo "==> Committing and pushing..."
[[ -d .git ]] || git init -q
git add Formula README.md bin .github
git commit -qm "raven $VERSION: seed tap" || echo "  (nothing new to commit)"
git branch -M main
git remote get-url origin >/dev/null 2>&1 || \
  git remote add origin "https://github.com/$OWNER/$TAP.git"
git push -u origin main

cat <<EOF

Done. Next:
  1. Settings > Branches: require the "test" check on 'main'.
  2. Create the tap-write secret in jbearak/raven and flip the bump on:
       gh secret   set HOMEBREW_TAP_TOKEN   -R $OWNER/raven           # paste the token
       gh variable set ENABLE_HOMEBREW_BUMP -R $OWNER/raven --body true
  3. Verify:
       brew install $OWNER/raven/raven && raven --version
EOF
