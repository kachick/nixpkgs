{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "brush";
  version = "0.2.14";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    tag = "brush-shell-v${version}";
    hash = "sha256-g9ZvatbNDWlPya3rWjt120LPhp4Io6KHTWXlMddm4zs=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-SLlIC847GEM5/0cX9PdLFtNaZMMSwUBhaKWt5tFawVg=";

  meta = {
    description = "Bash/POSIX-compatible shell implemented in Rust";
    homepage = "https://github.com/reubeno/brush";
    changelog = "https://github.com/reubeno/brush/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kachick ];
    mainProgram = "brush";
  };
}
