{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
}:

buildGoModule (finalAttrs: {
  pname = "git-wt";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "git-wt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hy9h9QY59h7mp0W2B4cRz8SQFtAGp+2puRtM6ojfKds=";
  };

  vendorHash = "sha256-C8c/AG/TNsIKrnYcK7k/NFajfgZE25xD1QNscyrucfo=";

  nativeCheckInputs = [ git ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/k1LoW/git-wt/version.Version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Git subcommand that makes git worktree simple";
    homepage = "https://github.com/k1LoW/git-wt";
    changelog = "https://github.com/k1LoW/git-wt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryoppippi ];
    mainProgram = "git-wt";
  };
})
