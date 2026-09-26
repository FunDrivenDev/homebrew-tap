# rlvdx/tap

Homebrew casks for apps whose sources stay private. Each app's repository builds and releases it, then the [`publish-cask`](.github/actions/publish-cask/action.yml) action copies the archive to a release here and writes its cask into `Casks/`.

```sh
brew install rlvdx/tap/memo
```

The apps are ad-hoc signed, without an Apple Developer ID; their casks lift the quarantine flag so Gatekeeper lets them open.

## Publishing from an app repository

In a workflow that runs once the app's own release is published, with the archive in the working directory and a `TAP_TOKEN` secret able to write this repository's contents:

```yaml
- uses: rlvdx/homebrew-tap/.github/actions/publish-cask@main
  with:
    cask: memo
    version: ${{ github.event.release.tag_name }}
    archive: memo-*-macos-arm64.zip
    definition: packaging/memo.rb
    token: ${{ secrets.TAP_TOKEN }}
```

The definition is the app's cask; the action replaces its `version` and `sha256` lines. Its `url` points at `https://github.com/rlvdx/homebrew-tap/releases/download/<cask>-#{version}/<archive name>`.
