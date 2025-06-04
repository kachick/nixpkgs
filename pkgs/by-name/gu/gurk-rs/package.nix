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
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "boxdot";
    repo = "gurk-rs";
    tag = "v${version}";
    hash = "sha256-xpdQ2LyARJYCn0cLH7drSO4w4S47ZzQLkLnwCHY4t5c=";
  };

  postPatch = ''
    rm .cargo/config.toml
  '';

  useFetchCargoVendor = true;

  cargoHash = "sha256-D/v2bVPo3BHwCsZns+U1lsr9Snuz941GkkwzBptxeZk=";

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

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Signal Messenger client for terminal";
    mainProgram = "gurk";
    homepage = "https://github.com/boxdot/gurk-rs";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ devhell ];
  };
}
