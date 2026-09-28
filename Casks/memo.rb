# The cask the Publish workflow writes into FunDrivenDev/homebrew-tap, with its version and
# sha256 filled in.
cask "memo" do
  version "0.1.2"
  sha256 "1638a635cd8ec6afc0bc436bc5443d8d88a9999ea88aee3329b6fc719344a657"

  url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/memo-#{version}/memo-#{version}-macos-arm64.zip"
  name "memo"
  desc "Keyboard-driven reader for the plans and reports Claude Code writes"
  homepage "https://github.com/FunDrivenDev/memo"

  depends_on arch: :arm64
  depends_on macos: ">= :ventura"

  app "memo.app"

  # memo is ad-hoc signed, not signed with a Developer ID, so Gatekeeper would refuse
  # to open it while it carries the quarantine flag of the download.
  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{appdir}/memo.app"]
  end

  zap trash: [
    "~/Library/Caches/dev.rlvdx.memo",
    "~/Library/WebKit/dev.rlvdx.memo",
  ]
end
