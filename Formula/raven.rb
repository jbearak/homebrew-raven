# Binary-download formula: installs the prebuilt `raven` from a GitHub Release
# zip (built by jbearak/raven's release-build.yml). This is NOT a Homebrew
# bottle and NOT a build-from-source formula — `brew install` just extracts the
# release archive and drops the binary into the keg. The URL version and sha256
# are kept current by the `bump-homebrew` job in jbearak/raven, which opens
# a PR here on every `v*` release.
#
# Apple Silicon (arm64) only — Intel macOS is intentionally unsupported.
#
# NOTE: homebrew/core already ships a DIFFERENT formula named `raven`
# (CycodeLabs' CI/CD scanner). Always install fully-qualified:
#   brew install jbearak/raven/raven
class Raven < Formula
  desc "Static analyzer for the R language (LSP server + CLI)"
  homepage "https://github.com/jbearak/raven"
  url "https://github.com/jbearak/raven/releases/download/v0.20.3/raven-macos-arm64.zip"
  sha256 "61dcc1faea334074d46fff007be367b63d127f2c43862b01d3cc9ebb947483f0"
  license "GPL-3.0-or-later"

  # Drives `brew livecheck` / `brew bump` off the upstream GitHub releases.
  # The automated bump PR is the source of truth; this is a manual safety net.
  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    # The release zip holds `raven` and `LICENSE` at its root (see
    # release-build.yml "Create archive"). Take only the binary.
    bin.install "raven"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/raven --version")
  end
end
