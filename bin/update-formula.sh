#!/usr/bin/env bash
# Update Formula/raven.rb to a new raven version + Apple Silicon checksum.
#
#   bin/update-formula.sh <version> <macos-arm64.zip>
#
# Single source of truth for the formula edit, called by BOTH:
#   - bootstrap.sh                            (initial seed of this repo)
#   - the bump-homebrew job in jbearak/raven  (per-release PR)
# so the two paths can never drift. Edits in place; fails loudly unless every
# expected field is present exactly as intended afterward.
set -euo pipefail

VERSION="${1:?usage: update-formula.sh <version> <macos-arm64.zip>}"
ARM_ZIP="${2:?missing macos-arm64.zip}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA="$REPO_ROOT/Formula/raven.rb"

VERSION="${VERSION#v}"   # tolerate a leading "v" so we never write "vv0.11.2"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]] || { echo "bad version: $VERSION" >&2; exit 1; }

sha() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}
SHA_ARM="$(sha "$ARM_ZIP")"
[[ "$SHA_ARM" =~ ^[0-9a-f]{64}$ ]] || { echo "not a sha256: $SHA_ARM" >&2; exit 1; }

perl -0pi -e "s{/download/v[0-9][^/]*/}{/download/v$VERSION/}g" "$FORMULA"
perl -0pi -e "s/^  version \"[^\"]+\"/  version \"$VERSION\"/m" "$FORMULA"
# Single arch ⇒ exactly one sha256 line in the formula; replace it directly
# (the canonical `brew style` order puts `version` between `url` and `sha256`,
# so do not assume url/sha256 adjacency).
perl -pi -e "s/^  sha256 \"[0-9a-f]{64}\"/  sha256 \"$SHA_ARM\"/" "$FORMULA"

# Post-conditions — any failure means the formula shape changed; do not ship it.
err=0
[[ "$(grep -c "version \"$VERSION\"" "$FORMULA")" -eq 1 ]] || { echo "version not set exactly once" >&2; err=1; }
[[ "$(grep -c "download/v$VERSION/" "$FORMULA")" -eq 1 ]] || { echo "expected exactly 1 versioned URL" >&2; err=1; }
[[ "$(grep -cE '^  sha256 ' "$FORMULA")" -eq 1 ]] || { echo "expected exactly 1 sha256 line" >&2; err=1; }
grep -q "$SHA_ARM" "$FORMULA" || { echo "arm64 sha256 not written" >&2; err=1; }
! grep -q "0000000000000000000000000000000000000000000000000000000000000000" "$FORMULA" || { echo "placeholder sha256 still present" >&2; err=1; }
[[ "$err" -eq 0 ]] || exit 1

echo "Updated $FORMULA -> raven $VERSION (arm64: $SHA_ARM)"
