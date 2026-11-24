# Template for the tap formula. scripts/package-release.sh fills the three @...@ values and writes
# the result next to the release files. The formula installs the prebuilt command line tool from
# the release: building from source needs Swift tools 6.2, which a Mac with only the Command Line
# Tools of macOS 14 lacks, so the formula has no build step and no build dependency.
class AgentBalancer < Formula
  desc "Pick the Claude Code subscription account for your next launch"
  homepage "https://github.com/jakemismas/agent-balancer"
  url "https://github.com/jakemismas/agent-balancer/releases/download/v1.2.0-rc1/agent-balancer-1.2.0-rc1-arm64.tar.gz"
  version "1.2.0-rc1"
  sha256 "48423c597128e9cc28eb588b56492036cf32d770949443ee128d8f329d647ca3"
  license "MIT"

  # The release is built for Apple silicon and macOS 14. The binary links only system libraries,
  # so nothing else is needed: no Xcode, no Command Line Tools, no Swift.
  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    bin.install "bin/agent-balancer"
    (share/"agent-balancer/skill").install "skill/agent-balancer"
  end

  def caveats
    <<~EOS
      Before you remove this tool, run `agent-balancer uninstall` in your own terminal. It removes
      the files the tool made in ~/.agent-balancer and the links it made in account folders.

      To let your own Claude pick an account, link the skill folder into your skills folder:
        mkdir -p ~/.claude/skills && ln -s "#{HOMEBREW_PREFIX}/share/agent-balancer/skill/agent-balancer" ~/.claude/skills/agent-balancer
    EOS
  end

  test do
    # A prerelease formula is version X.Y.Z-rcN, and the tool reports the base version X.Y.Z.
    assert_match version.to_s.sub(/-rc\d+$/, ""), shell_output("#{bin}/agent-balancer --version")
    assert_path_exists share/"agent-balancer/skill/agent-balancer/SKILL.md"
  end
end
