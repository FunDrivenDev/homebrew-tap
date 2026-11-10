# The formula of toolbox, whose archives each release copies to a toolbox-<version> release
# of this repository (toolbox's repository is private).
class Toolbox < Formula
  desc "One CLI for the fundrivendev tooling: PR gate, worktrees, notes, sessions, hooks"
  # toolbox's repository is private, and brew audit requires a homepage that answers.
  homepage "https://github.com/FunDrivenDev/homebrew-tap"
  version "0.25.0"

  on_macos do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_arm64.tar.gz"
      sha256 "1be4fe98754c9172345fc255c257eae36c1402016097341c39b86ce0f4c990e2"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_amd64.tar.gz"
      sha256 "1dca23ab1c30263d62bdf3cafa9e8d397c4eba898bc4706c7a0cf9580d1b77e1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_arm64.tar.gz"
      sha256 "89b6bdf28dd21b36ffec6867db6ad6a56f650c8acd3f1b43deb2106d15b15a8b"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_amd64.tar.gz"
      sha256 "df5dcd6b79bfddecaae880f806b974f9eb3c54008175ff9f53880ebe5d8ba6b4"
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
