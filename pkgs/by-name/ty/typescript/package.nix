{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  versionCheckHook,
  writeShellApplication,
  nodejs,
  gnutar,
  nix-update,
  prefetch-npm-deps,
  gnused,
}:

buildNpmPackage (finalAttrs: {
  pname = "typescript";
  version = "5.8.3";

  # Prefer npmjs over the GitHub repository for source code.
  # The TypeScript project typically publishes stable, versioned code to npmjs,
  # whereas GitHub tags may sometimes include development versions.
  # For example:
  #   - https://github.com/microsoft/TypeScript/pull/61218#issuecomment-2911264050
  #   - https://github.com/microsoft/TypeScript/pull/60150#issuecomment-2648791588, 5.8.3 includes this 5.9 breaking change
  src = fetchurl {
    url = "https://registry.npmjs.org/typescript/-/typescript-${finalAttrs.version}.tgz";
    hash = "sha256-cuddvrksLm65o0y1nXT6tcLubzKgMkqJQF9hZdWgg3Q=";
  };

  postPatch =
    let
      repoSrc = fetchFromGitHub {
        owner = "microsoft";
        repo = "TypeScript";
        tag = "v${finalAttrs.version}";
        hash = "sha256-/XxjZO/pJLLAvsP7x4TOC+XDbOOR+HHmdpn+8qP77L8=";
      };
    in
    ''
      ln -s '${repoSrc}/package-lock.json' package-lock.json
    '';

  npmDepsHash = "sha256-/LkIqwuG0px/vbif9mVL9lHpv5KX8SaS7fD+4wiNaIA=";

  dontNpmBuild = true;

  makeCacheWritable = true;

  npmFlags = [
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/tsc";
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "${finalAttrs.pname}-updater";
      runtimeInputs = [
        nodejs
        gnutar
        nix-update
        prefetch-npm-deps
        gnused
      ];
      runtimeEnv = {
        PNAME = finalAttrs.pname;
        PKG_DIR = builtins.toString ./.;
      };
      text = builtins.readFile ./update.bash;
    });
  };

  meta = {
    description = "Superset of JavaScript that compiles to clean JavaScript output";
    homepage = "https://www.typescriptlang.org/";
    changelog = "https://github.com/microsoft/TypeScript/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "tsc";
  };
})
