# The formula of toolbox, whose archives each release copies to a toolbox-<version> release
# of this repository (toolbox's repository is private).
class Toolbox < Formula
  desc "One CLI for the fundrivendev tooling: PR gate, worktrees, notes, sessions, hooks"
  # toolbox's repository is private, and brew audit requires a homepage that answers.
  homepage "https://github.com/FunDrivenDev/homebrew-tap"
  version "0.40.0"

  on_macos do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_arm64.tar.gz"
      sha256 "cae6305b547d59a4f4ab43d8c196ff240bb13150b308884cf7e54fa12be1ca40"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_darwin_amd64.tar.gz"
      sha256 "e5428f07a15f230142d329e8a0e29921166bf4e10e1a4e25c29ec0854b745270"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_arm64.tar.gz"
      sha256 "3d81a4619d2b2c071bf178fbcf1fe1ce4d49819135b90afc9b7ca281e706ea9b"
    end
    on_intel do
      url "https://github.com/FunDrivenDev/homebrew-tap/releases/download/toolbox-#{version}/toolbox_#{version}_linux_amd64.tar.gz"
      sha256 "98bc2174368d5fea3d76d914608eb2b478539c8c1d65b41465ebbb2ee488cd13"
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
