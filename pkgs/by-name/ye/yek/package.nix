{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  nix-update-script,
  versionCheckHook,
}:
let
  version = "0.25.0";
in
rustPlatform.buildRustPackage {
  pname = "yek";
  version = version;

  src = fetchFromGitHub {
    owner = "bodo-run";
    repo = "yek";
    tag = "v${version}";
    hash = "sha256-6yHQyl4UnRQlmWkBbAvUEBZnrHW3GsrrFZyOU+p3mjE=";
  };

  cargoHash = "sha256-WheN8rk/LwKTVg0mDorbXGBvojISSu1KtknFkWmpLMk=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  env.OPENSSL_NO_VENDOR = 1;

  useNextest = true;

  checkFlags = [
    # Tests with git fail
    "--skip e2e_tests::test_git_boost_config"
    "--skip e2e_tests::test_git_integration"
    "--skip lib_tests::test_serialize_repo_with_git"
    "--skip priority_tests::test_get_recent_commit_times_empty_repo"
    "--skip priority_tests::test_get_recent_commit_times_with_git"
    "--skip priority_tests::test_get_recent_commit_times_git_failure"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;
  passthru.updateScript = nix-update-script { };

  # error: linker `aarch64-linux-gnu-gcc` not found
  postPatch = ''
    rm .cargo/config.toml
  '';

  meta = {
    description = "Serialize text files for LLM consumption";
    longDescription = ''
      Tool to read text-based files, chunk them, and serialize them for LLM consumption.
    '';
    homepage = "https://github.com/bodo-run/yek";
    changelog = "https://github.com/bodo-run/yek/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "yek";
    maintainers = with lib.maintainers; [ louis-thevenet ];
  };
}
