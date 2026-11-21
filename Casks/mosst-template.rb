# The cask `just publish` writes into FunDrivenDev/homebrew-tap, with its version and
# sha256 filled in.
cask "mosst-template" do
  version "0.1.0"
  sha256 "df0ff12a329745f5b1d19c7ceaac3f1130c72a1e266443faf38744a3f939725d"

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
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "mosst-template.app"], base: :appdir
  end

  zap trash: [
    "~/Library/Application Support/dev.rlvdx.mossttemplate",
    "~/Library/Caches/dev.rlvdx.mossttemplate",
    "~/Library/WebKit/dev.rlvdx.mossttemplate",
  ]
end
