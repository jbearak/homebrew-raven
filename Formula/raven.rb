# Binary-download formula: installs the prebuilt `raven` from a GitHub Release
# zip (built by jbearak/raven's release-build.yml). This is NOT a Homebrew
# bottle and NOT a build-from-source formula — `brew install` just extracts the
# release archive and drops the binary into the keg. Version + sha256 are kept
# current automatically by the `bump-homebrew` job in jbearak/raven, which opens
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
  url "https://github.com/jbearak/raven/releases/download/v0.17.0/raven-macos-arm64.zip"
  version "0.17.0"
  sha256 "6f6ae0f9c71cd28c4f8d2a4df3300ec461a41bbfa5eba708b6f106d91ef29e78"
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
