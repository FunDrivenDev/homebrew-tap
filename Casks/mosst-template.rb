# The cask `just publish` writes into FunDrivenDev/homebrew-tap, with its version and
# sha256 filled in.
cask "mosst-template" do
  version "0.1.1"
  sha256 "e0126a5991cd9c7bb1f4781526d732fcec32c0c21d43a1fe2b547c26e8ded02e"

  url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/mosst-template-#{version}/mosst-template-#{version}-macos-arm64.zip"
  name "mosst-template"
  desc "Starting point of every MOSST app"
  homepage "https://github.com/FunDrivenDev/homebrew-tap"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "mosst-template.app"

  # mosst-template is ad-hoc signed, not signed with a Developer ID, so Gatekeeper would refuse
  # to open it while it carries the quarantine flag of the download.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/mosst-template.app"]
  end

  zap trash: [
    "~/Library/Application Support/dev.rlvdx.mossttemplate",
    "~/Library/Caches/dev.rlvdx.mossttemplate",
    "~/Library/WebKit/dev.rlvdx.mossttemplate",
  ]
end
