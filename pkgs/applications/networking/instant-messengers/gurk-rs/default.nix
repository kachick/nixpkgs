{ stdenv
, lib
, protobuf
, rustPlatform
, fetchFromGitHub
, Cocoa
, pkgsBuildHost
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "gurk-rs";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "boxdot";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ZVpI60pZZCLRnKdC80P8f63gE0+Vi1lelhyFPAhpHyU=";
  };

  postPatch = ''
    rm .cargo/config.toml
  '';

  useFetchCargoVendor = true;

  cargoHash = "sha256-YeRrd2ybCTVAu7EyAZg82eqUP9wvsA8GArdn0oY1eMg=";

  nativeBuildInputs = [ protobuf pkg-config ];

  buildInputs = [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ Cocoa ];

  NIX_LDFLAGS = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [ "-framework" "AppKit" ];

  PROTOC = "${pkgsBuildHost.protobuf}/bin/protoc";

  OPENSSL_NO_VENDOR = true;

  useNextest = true;

  meta = with lib; {
    description = "Signal Messenger client for terminal";
    mainProgram = "gurk";
    homepage = "https://github.com/boxdot/gurk-rs";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ devhell ];
  };
}
