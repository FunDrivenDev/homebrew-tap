# The cask the Release workflow writes into FunDrivenDev/homebrew-tap, with its version and
# sha256 filled in.
cask "maquereau" do
  version "0.1.3"
  sha256 "68484ddab4c0f6fe544c5a2b903134709c90069203266fc0d2feee33db023c2e"

  url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/maquereau-#{version}/maquereau-#{version}-macos-arm64.zip"
  name "maquereau"
  desc "Keyboard-driven focus on four priority topics, their issues and sessions"
  homepage "https://github.com/FunDrivenDev/maquereau"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "maquereau.app"

  # maquereau is ad-hoc signed, not signed with a Developer ID, so Gatekeeper would refuse
  # to open it while it carries the quarantine flag of the download.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/maquereau.app"]
  end

  zap trash: [
    "~/Library/Application Support/dev.fundrivendev.maquereau",
    "~/Library/Caches/dev.fundrivendev.maquereau",
    "~/Library/WebKit/dev.fundrivendev.maquereau",
  ]
end
