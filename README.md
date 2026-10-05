# fundrivendev/tap

Homebrew casks for the Fun Driven Stuff apps. Each app's repository builds and releases it, then the [`publish-cask`](.github/actions/publish-cask/action.yml) action copies the archive to a release here and writes its cask into `Casks/` through a pull request, merged as soon as this repository's rules allow.

```sh
brew install fundrivendev/tap/memo
```

The apps are ad-hoc signed, without an Apple Developer ID; their casks lift the quarantine flag so Gatekeeper lets them open.

## Publishing from an app repository

In a workflow that runs once the app's own release is published, with the archive in the working directory and a `TAP_TOKEN` secret able to write this repository's contents and pull requests (fine-grained token: "Contents" and "Pull requests", read and write):

```yaml
- uses: FunDrivenDev/homebrew-tap/.github/actions/publish-cask@main
  with:
    cask: memo
    version: ${{ github.event.release.tag_name }}
    archive: memo-*-macos-arm64.zip
    definition: packaging/memo.rb
    token: ${{ secrets.TAP_TOKEN }}
    signing-key: ${{ secrets.SIGNING_KEY }}
```

The definition is the app's cask; the action replaces its `version` and `sha256` lines. Its `url` points at `https://github.com/FunDrivenDev/homebrew-tap/releases/download/<cask>-#{version}/<archive name>`.

The action commits each cask as Fun Driven Stuff <stuff@fundriven.dev>, signed with `SIGNING_KEY`, an SSH key registered as a signing key on the GitHub account that holds that address; GitHub then shows the commit as verified. It pushes that commit to a `cask/<cask>-<version>` branch, opens a pull request from it and asks `gh pr merge --auto --squash --delete-branch` to merge it: at once while `main` requires no check, else once its checks pass. A rerun reuses the open pull request, and does nothing once the cask is at the version.

## Checks

Every check is a `just` recipe, with the tools pinned in `mise.toml` (`just init` installs them and the git hooks of `hk.pkl`). Homebrew itself is the one tool mise cannot pin: the casks are checked with the brew of the Mac, or of the runner image in CI.

| Recipe | Runs |
| --- | --- |
| `just lint [scope] [family]` | shellcheck on `scripts/`, actionlint on the workflows, then `brew style` and `brew audit --cask --strict --online` on the casks |
| `just test [scope]` | the tests of the CI change classifier |
| `just check [scope]` | `lint`, then `test` |
| `just audit` | gitleaks over the history (`.gitleaks.toml` adds a home-path rule), zizmor on the workflows and the action |
| `just fmt [scope]` | `brew style --fix` on the casks |

The audit of a cask downloads its archive: the `url` must answer and the `sha256` must match. It leaves out the livecheck audits, since every cask releases from this repository and GitHub's latest release is then some other cask's. `brew audit` only takes the casks of a tapped tap, so `just lint` taps the checkout under a name of its own for the run and removes it after; the installed `fundrivendev/tap` stays untouched.

On a pull request, CI (`.github/workflows/ci.yml`) runs only what the change needs: `just ci-changes` sorts the changed files by kind, docs run nothing, a cask runs the cask checks, a script the lint, and CI or tooling files everything. The audit runs on every pull request, and a push to `main`, a manual run and the Monday run check everything. The casks are checked on `macos-26`, where they install and where Homebrew comes with the image (the tap is public, so macOS minutes cost nothing); the rest runs on `ubuntu-24.04`. `ci-ok` gathers the results and is the check FunDrivenDev's org ruleset requires on `main`, so every change, the release jobs' cask updates included, lands through a pull request. `just act` runs the workflow locally: the Linux jobs in Docker, the cask job on the Mac itself.
