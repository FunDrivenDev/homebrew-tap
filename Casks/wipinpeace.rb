# The cask the Release workflow writes into FunDrivenDev/homebrew-tap, with its version and
# sha256 filled in.
cask "wipinpeace" do
  version "0.1.5"
  sha256 "83c66037c85f0062e6fa1efa78d74b9546272f2395836dc3f60fa5a29d6b66a2"

  url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/wipinpeace-#{version}/wipinpeace-#{version}-macos-arm64.zip"
  name "wipinpeace"
  desc "Keyboard-driven focus on four priority topics, their issues and sessions"
  homepage "https://github.com/FunDrivenDev/wipinpeace"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "wipinpeace.app"

  # wipinpeace is ad-hoc signed, not signed with a Developer ID, so Gatekeeper would refuse
  # to open it while it carries the quarantine flag of the download.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/wipinpeace.app"]
  end

  zap trash: [
    "~/Library/Application Support/dev.fundrivendev.wipinpeace",
    "~/Library/Caches/dev.fundrivendev.wipinpeace",
    "~/Library/WebKit/dev.fundrivendev.wipinpeace",
  ]
end
