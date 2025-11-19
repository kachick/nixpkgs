{
  lib,
  fetchCrate,
  rustPlatform,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fontspector-cli";
  version = "1.5.0";

  src = fetchCrate {
    pname = "fontspector";
    inherit (finalAttrs) version;
    hash = "sha256-09u50o4dg7keJgFC4xlRJ0LtkR7ZxmxnqLdEVKpE77E=";
  };

  cargoHash = "sha256-zY4PtuQuUMvuR7gr42iytR2CW7bQBfbB0L6JE8cSQh8=";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = false;
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version=skip" ];
    };
  };

  meta = {
    description = "Fast command-line tool for JSON Schema validation";
    homepage = "https://github.com/fonttools/fontspector";
    changelog = "https://github.com/fonttools/fontspector/blob/fontspector-v${finalAttrs.version}/fontspector-cli/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "fontspector-cli";
  };
})
