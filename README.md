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
