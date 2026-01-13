{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "filen-cli-rs";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "FilenCloudDienste";
    repo = "filen-rs";
    tag = "filen-cli@v${finalAttrs.version}";
    hash = "sha256-3xYf5/s4eJ3T5Kv5NMQkpqNQNzk3cOC47IvXjuPrUCU=";
  };

  cargoHash = "sha256-N5CD5nNu+HGWh+R+08KWBcJwZ6CesB/V0XMIlulL3cw=";

  # cargoRoot = "filen-cli";
  # buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoBuildFlags = [
    "--package=filen-cli"
  ];

  RUSTC_BOOTSTRAP = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust rewrite of filen-cli";
    homepage = "https://github.com/FilenCloudDienste/filen-rs";
    changelog = "https://github.com/FilenCloudDienste/filen-cli-releases/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "filen-cli";
  };
})
