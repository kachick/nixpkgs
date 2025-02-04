{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  versionCheckHook,
  # nix-update-script,
  brush,
}:

rustPlatform.buildRustPackage rec {
  pname = "brush";
  version = "0.2.15";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    tag = "brush-shell-v${version}";
    hash = "sha256-hPF2nXYXAM+5Lz2VJw9vZ6RFZ40y+YkO94Jc/sLUYsg=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-A4v4i6U6BwUMNTI/TO7wTQvNVtQYKGiQfDXOCy8hFTE=";

  # Workaround for errors: Running tests/compat_tests.rs
  # error: unexpected argument '--test-threads' found
  # doCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${meta.mainProgram}";
  versionCheckProgramArg = [ "--version" ];

  # TODO: Should adjust for their tag names
  # passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bash/POSIX-compatible shell implemented in Rust";
    homepage = "https://github.com/reubeno/brush";
    changelog = "https://github.com/reubeno/brush/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kachick ];
    mainProgram = "brush";
  };
}
