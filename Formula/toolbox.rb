# The formula of toolbox, whose archives each release copies to a toolbox-<version> release
# of this repository (toolbox's repository is private).
class Toolbox < Formula
  desc "One CLI for the fundrivendev tooling: dod, worktrees, notes, sessions, hooks"
  # toolbox's repository is private, and brew audit requires a homepage that answers.
  homepage "https://github.com/FunDrivenDev/homebrew-tap"
  version "0.13.1"

  on_macos do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_arm64.tar.gz"
      sha256 "ad47e500cfe274abfc6a55cfd6609cbb3755c7a53090c58e965352ed5ab39df7"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_amd64.tar.gz"
      sha256 "8673fd66e7c93dbbece34f17b52ed3aef7a291437e49ea2a8e9fe6718fe9e604"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_arm64.tar.gz"
      sha256 "7ee8527ddaeaab851a9f655e6217aaeb760a703d25a9468091d5bdc76bef614e"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_amd64.tar.gz"
      sha256 "c9477d10d133cee510c4e78debedc222be5993407f3822ff1d9b467d6cfe18ee"
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
