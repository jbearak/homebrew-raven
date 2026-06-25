# homebrew-raven

A [Homebrew](https://brew.sh) tap for [`raven`](https://github.com/jbearak/raven),
a static analyzer for the R language. The formula installs a **prebuilt macOS
(Apple Silicon) binary** from raven's GitHub Releases — no compilation, no Rust
toolchain.

## Install

> [!IMPORTANT]
> `homebrew/core` ships a *different* tool also named `raven` (CycodeLabs' CI/CD
> scanner). **Always use the fully-qualified name** so you get this one:

```sh
brew install jbearak/raven/raven
```

`brew tap jbearak/raven` is implied by the fully-qualified install. Using the
fully-qualified path also means you trust only *this* formula, not the whole tap
— relevant as Homebrew tightens [tap trust](https://docs.brew.sh/Taps).

## Upgrade

```sh
brew update
brew upgrade jbearak/raven/raven
```

## Brewfile

```ruby
tap "jbearak/raven"
brew "jbearak/raven/raven"
```

Then `brew bundle --file=/path/to/Brewfile`.

## Supported platforms

macOS on Apple Silicon (`arm64`) only. The formula declares `depends_on :macos`
and `depends_on arch: :arm64`; Intel macOS and Linux are intentionally out of
scope.

The shipped binary is **not Developer ID signed or notarized**. Homebrew's
command-line install path does not trip the GUI Gatekeeper prompt, and the
arm64 binary carries the linker's ad-hoc signature, so `raven` runs after a
normal `brew install`. If your environment enforces an EDR/MDM policy that
blocks unsigned executables, sign + notarize in raven's release build before
relying on this tap. (Release artifacts already carry GitHub build-provenance
attestations.)

## How updates land here

The `bump-homebrew` job in [`jbearak/raven`](https://github.com/jbearak/raven)
runs after each `v*` release is published, recomputes the Apple Silicon sha256
from the release artifact, and opens a **PR** against this repo bumping
`version` and the checksum. CI on that PR (`brew audit`/`install`/`test`) must
pass before it merges — a broken formula never reaches users via a silent push.

## Rollback / bad release

- **Never mutate a published release asset.** The pinned `sha256` is deliberate:
  silently replacing a zip will make `brew` refuse it (checksum mismatch) rather
  than ship a swapped binary.
- To pull a bad version, **revert the formula PR** (or commit) to the previous
  `version` + checksum, or cut a new patch release upstream and let the bump PR
  carry the fix forward.
- For a formula-only fix against the *same* upstream version (no URL/sha
  change), bump the formula `revision` so clients reinstall.

## Maintainer: the tap-write token

The bump job authenticates with a secret named `HOMEBREW_TAP_TOKEN` stored in
`jbearak/raven`. A leaked token can ship arbitrary formula Ruby to anyone who
installs from this tap, so:

- Prefer a **GitHub App** installation token scoped to this repo, or a
  **fine-grained PAT** restricted to `jbearak/homebrew-raven` with **Contents:
  write** and **Pull requests: write** only.
- Set an expiration and document a rotation/revocation step.
