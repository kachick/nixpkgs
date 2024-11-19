{ lib, stdenv, fetchCrate, rustPlatform, CoreFoundation, Security }:

let
  pname = "dprint";
  version = "0.47.2";
  testWasmPlugin = builtins.fetchurl {
    url = "https://github.com/dprint/dprint/raw/refs/tags/${version}/crates/test-plugin/test_plugin.wasm";
    sha256 = "1llg9x35xkxl49my268ncq93favqrqipv6f4750rcqknpqah825m";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-zafRwiXfRACT6G408pXLCk7t6akabOs1VFLRF9SeNWI=";
  };

  cargoHash = "sha256-86ecnwDDVvgXgBBodP2rSZOn+R52Jap8RCKILttGOn8=";

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ CoreFoundation Security ];

  preConfigure = ''
    substituteInPlace "$src/src/test_helpers.rs" \
      --replace-fail '../../test-plugin/test_plugin_0_1_0.wasm' '${testWasmPlugin}'
  '';

  preCheck = ''
    export DPRINT_CACHE_DIR="$(mktemp --directory)
  '';

  meta = with lib; {
    description = "Code formatting platform written in Rust";
    longDescription = ''
      dprint is a pluggable and configurable code formatting platform written in Rust.
      It offers multiple WASM plugins to support various languages. It's written in
      Rust, so it’s small, fast, and portable.
    '';
    changelog = "https://github.com/dprint/dprint/releases/tag/${version}";
    homepage = "https://dprint.dev";
    license = licenses.mit;
    maintainers = with maintainers; [ khushraj ];
    mainProgram = "dprint";
  };
}
