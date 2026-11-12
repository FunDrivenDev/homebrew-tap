# The formula of toolbox, whose archives each release copies to a toolbox-<version> release
# of this repository (toolbox's repository is private).
class Toolbox < Formula
  desc "One CLI for the fundrivendev tooling: PR gate, worktrees, notes, sessions, hooks"
  # toolbox's repository is private, and brew audit requires a homepage that answers.
  homepage "https://github.com/FunDrivenDev/homebrew-tap"
  version "0.30.0"

  on_macos do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_arm64.tar.gz"
      sha256 "ff6c3345423585f188b892521378c5c87b522f5f762104c40af4e8befe315e7e"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_amd64.tar.gz"
      sha256 "2a262a4bc0342db483f29bb2ce2a2418593b8dee630bd7a3c27cee1dfe50fdba"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_arm64.tar.gz"
      sha256 "2e0d29acb3b1ef2997dfd7f4d80dae1db8a4dd45ed19cfb6424b2929906cb6fb"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_amd64.tar.gz"
      sha256 "947fa2d60f0e470b6d6b2f45d8860214ff26ffbe104b41dca346610c0f85ad6d"
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
