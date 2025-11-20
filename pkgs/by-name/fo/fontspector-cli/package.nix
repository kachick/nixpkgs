{
  lib,
  # fetchCrate,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fontspector-cli";
  version = "1.5.1";

  # src = fetchCrate {
  #   pname = "fontspector";
  #   inherit (finalAttrs) version;
  #   hash = "sha256-09u50o4dg7keJgFC4xlRJ0LtkR7ZxmxnqLdEVKpE77E=";
  # };

  src = fetchFromGitHub {
    owner = "fonttools";
    repo = "fontspector";
    tag = "fontspector-v${finalAttrs.version}";
    hash = "sha256-kkedKDhCXMPWd8l3VpkNBCR6DpudK7RwUlXczExFxhk=";
  };

  cargoHash = "sha256-9jewRzUtTKnIMnoV8mWUZJXsf9RvHoov+89g0SwUc9M=";

  # minreq::get appears not supporting local files.
  postPatch = ''
    substituteInPlace ./fontspector-checkapi/build.rs \
      --replace-fail '"https://learn.microsoft.com/en-gb/typography/opentype/spec/scripttags"' '"file:${./scripttags.html}"' \
      --replace-fail '"https://learn.microsoft.com/en-gb/typography/opentype/spec/languagetags"' '"file:${./languagetags.html}"'
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # cargoBuildFlags = [
  #   "--package=fontspector-cli"
  # ];

  doCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = false;
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^fontspector-v([0-9.]+)$" ];
    };
  };

  meta = {
    description = "Quality control for OpenType fonts";
    homepage = "https://github.com/fonttools/fontspector";
    changelog = "https://github.com/fonttools/fontspector/blob/fontspector-v${finalAttrs.version}/fontspector-cli/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "fontspector-cli";
    platforms = with lib.platforms; unix ++ windows;
  };
})
