# The formula of toolbox, whose archives each release copies to a toolbox-<version> release
# of this repository (toolbox's repository is private).
class Toolbox < Formula
  desc "One CLI for the fundrivendev tooling: dod, worktrees, notes, sessions, hooks"
  # toolbox's repository is private, and brew audit requires a homepage that answers.
  homepage "https://github.com/FunDrivenDev/homebrew-tap"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_arm64.tar.gz"
      sha256 "fb5edfd657cbb81edd29d9a7383360eb5bdc3dcceda191b36a6e3a56ec629dfc"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_amd64.tar.gz"
      sha256 "1f2ae7a825e8ca8692aabfe238817cb9fada433e96be5d4f6bcebe116741b8ad"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_arm64.tar.gz"
      sha256 "01ca6829611cb5b48e6252b679bcf7b0a505cdf29fbf4c095517a4e6c108d889"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_amd64.tar.gz"
      sha256 "ec91fa907c30be84609b43b523307b4f33b3281f0c0774750e8b06790a4de1d4"
    end
  end

  def install
    bin.install "toolbox"
    # git runs gpg.ssh.program with its own argv; under this name the binary is
    # `toolbox git ssh-sign`.
    bin.install_symlink "toolbox" => "toolbox-git-ssh-sign"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/toolbox --version")
    assert_path_exists bin/"toolbox-git-ssh-sign"
  end
end
