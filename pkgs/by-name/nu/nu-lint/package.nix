{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  rustPlatform,
  nix-update-script,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu-lint";
  version = "0.0.131";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wvhulle";
    repo = "nu-lint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MxxKHC3B5DLvVlDLh7Pojwbjd9FUjR6SK0AE49/qhTk=";
  };

  cargoHash = "sha256-OSkiB03/VL67kqh7OsekiMRoL8e0tOEGQG1CLKScE2w=";

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isDarwin [
    # Avoids "couldn't find any valid shared libraries matching: ['libclang.dylib']" error on darwin in sandbox mode.
    rustPlatform.bindgenHook
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linter for the Nu shell scripting language";
    homepage = "https://codeberg.org/wvhulle/nu-lint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kpbaks ];
    platforms = lib.platforms.all;
    mainProgram = "nu-lint";
  };
})
