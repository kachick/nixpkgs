{
  lib,
  fetchFromGitHub,
  rustPlatform,
  # writableTmpDirAsHomeHook,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rumdl";
  version = "0.0.146";

  src = fetchFromGitHub {
    owner = "rvben";
    repo = "rumdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0aeBVapWJ+1Y/D7WA1oYACD8Mr0tSLiv+ojJhZ3i3pI=";
  };

  cargoHash = "sha256-yrDf0+QMBzHhGNBTZp9gQNqH3USagpJklRDrUvjHnbw=";

  cargoBuildFlags = [
    "--bin=rumdl"
  ];

  cargoTestFlags = [
    # test-ci: https://github.com/rvben/rumdl/blob/da7b027e6bc7161d0752e48724102fd59c93c5f8/Makefile#L101-L102
    "--profile ci"
  ];

  useNextest = true;

  # nativeCheckInputs = [
  #   writableTmpDirAsHomeHook
  # ];

  checkFlags = [
    # Skip Windows tests
    "--skip comprehensive_windows_tests"
    "--skip windows_vscode_tests"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Markdown Linter";
    homepage = "https://github.com/rvben/rumdl";
    changelog = "https://github.com/rvben/rumdl/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "rumdl";
    platforms = with lib.platforms; unix ++ windows;
  };
})
