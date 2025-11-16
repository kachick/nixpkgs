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
  version = "0.7.2";

  src = fetchFromGitHub {
    # It appears nixpkgs's version updates has stopped until https://github.com/whisperfish/presage/compare/473c70d...2acc5328a
    # I suspect nixpkgs does not correctly handle the difference editions 2021(presage) and 2024(presage-store-sqlite, gurk-rs).
    # This is my personal and temporary for avoiding the problem.
    owner = "kachick";
    repo = "gurk-rs";
    rev = "2fd0c840ca6e201d42c3d2bae5a53ee55118109b";
    hash = "sha256-lQIj8w6FhEHIzWgNpXNOF/qzlE6orJpUlMZh0lsLi2w=";
  };

  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-mQPRnK87ZgIJCALs8XVf6zQEoOM5RZVe0CigPmwdG4w=";

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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=skip" ]; };

  meta = with lib; {
    description = "Signal Messenger client for terminal";
    mainProgram = "gurk";
    homepage = "https://github.com/boxdot/gurk-rs";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ devhell ];
  };
}
