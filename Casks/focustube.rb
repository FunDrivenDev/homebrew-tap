# The cask `just publish` writes into FunDrivenDev/homebrew-tap, with its version and
# sha256 filled in.
cask "focustube" do
  version "0.1.0"
  sha256 "dccc22f9a20006b4b53aa9cce6d2f2f296aa53c9672c334f5f523c38863a4cf1"

  url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/focustube-#{version}/focustube-#{version}-macos-arm64.zip"
  name "focustube"
  desc "Focused, learning-oriented YouTube feed of the channels and topics you choose"
  homepage "https://github.com/FunDrivenDev/homebrew-tap"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "focustube.app"

  # focustube is ad-hoc signed, not signed with a Developer ID, so Gatekeeper would refuse
  # to open it while it carries the quarantine flag of the download.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/focustube.app"]
  end

  zap trash: [
    "~/Library/Application Support/dev.fundrivendev.focustube",
    "~/Library/Caches/dev.fundrivendev.focustube",
    "~/Library/WebKit/dev.fundrivendev.focustube",
  ]
end
