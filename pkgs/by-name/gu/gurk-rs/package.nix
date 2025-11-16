{
  stdenv,
  lib,
  protobuf,
  rustPlatform,
  fetchFromGitHub,
  pkgsBuildHost,
  openssl,
  pkg-config,
  writableTmpDirAsHomeHook,
  versionCheckHook,
  nix-update-script,
  gurk-rs,
}:

rustPlatform.buildRustPackage rec {
  pname = "gurk-rs";
  version = "0.7.2-unstable-2025-11-16";

  src = fetchFromGitHub {
    # The Nixpkgs version update seems stuck since the changes in this commit range were added: https://github.com/whisperfish/presage/compare/473c70d...2acc5328a.
    # I guess the problem is that Nixpkgs does not handle the Rust edition difference (presage-2021 vs presage-store-sqlite-2024, gurk-rs-2024) correctly.
    # This is my temporary fork to avoid the issue.
    owner = "kachick";
    repo = "gurk-rs";
    rev = "7eb62779ce32bb3e380e2e4e4dca1df7bf5eaade";
    hash = "sha256-uPE7qXQlzkqkdxyHIqnXs59lYiwaYARi99Kwtz3kuko=";
  };

  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-Naykepi3t36z2pcBB/+emcDYRexJtW9EJVGw17znKOo=";

  nativeBuildInputs = [
    protobuf
    pkg-config
  ];

  buildInputs = [ openssl ];

  NIX_LDFLAGS = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
    "-framework"
    "AppKit"
  ];

  PROTOC = "${pkgsBuildHost.protobuf}/bin/protoc";

  OPENSSL_NO_VENDOR = true;

  useNextest = true;

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${meta.mainProgram}";
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=gurk-rs-0.7.2-sync-rust-edition" ];
  };

  meta = with lib; {
    description = "Signal Messenger client for terminal";
    mainProgram = "gurk";
    homepage = "https://github.com/boxdot/gurk-rs";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ devhell ];

    # On Darwin, this package requires sandbox-relaxed to build.
    # If the sandbox is enabled, `fetch-cargo-vendor-util` causes errors.
    # This issue may be related to: https://github.com/NixOS/nixpkgs/issues/394972
    # broken = stdenv.hostPlatform.isDarwin;
  };
}
