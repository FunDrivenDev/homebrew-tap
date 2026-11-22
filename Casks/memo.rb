# The cask the Publish workflow writes into FunDrivenDev/homebrew-tap, with its version and
# sha256 filled in.
cask "memo" do
  version "0.3.2"
  sha256 "16dfe2043289f6a3e18a663e6b43d16b183ce3def1eea1481f9641bfbf32df78"

  url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/memo-#{version}/memo-#{version}-macos-arm64.zip"
  name "memo"
  desc "Keyboard-driven reader for the plans and reports Claude Code writes"
  homepage "https://github.com/FunDrivenDev/homebrew-tap"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "memo.app"

  # memo is ad-hoc signed, not signed with a Developer ID, so Gatekeeper would refuse
  # to open it while it carries the quarantine flag of the download.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/memo.app"]
  end

  zap trash: [
    "~/Library/Caches/dev.rlvdx.memo",
    "~/Library/WebKit/dev.rlvdx.memo",
  ]
end
