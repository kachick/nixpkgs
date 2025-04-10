{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  versionCheckHook,
  writeShellApplication,
  curl,
  jq,
  ripgrep,
  common-updater-scripts,
}:

let
  # These files can be found in Stockfish/src/evaluate.h
  nnueBigFile = "nn-1111cefa1111.nnue";
  nnueBigHash = "sha256-ERHO+hERa3cWG9SxTatMUPJuWSDHVvSGFZK+Pc1t4XQ=";
  nnueBig = fetchurl {
    url = "https://tests.stockfishchess.org/api/nn/${nnueBigFile}";
    hash = nnueBigHash;
  };
  nnueSmallFile = "nn-37f18f62d772.nnue";
  nnueSmall = fetchurl {
    url = "https://tests.stockfishchess.org/api/nn/${nnueSmallFile}";
    hash = "sha256-N/GPYtdy8xB+HWqso4mMEww8hvKrY+ZVX7vKIGNaiZ0=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fishnet";
  version = "2.9.4";

  src = fetchFromGitHub {
    owner = "lichess-org";
    repo = "fishnet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JhllThFiHeC/5AAFwwZQ0mgbENIWP1cA7aD01DeDVL8=";
    fetchSubmodules = true;
  };

  postPatch = ''
    cp -v '${nnueBig}' 'Stockfish/src/${nnueBigFile}'
    cp -v '${nnueBig}' 'Fairy-Stockfish/src/${nnueBigFile}'
    cp -v '${nnueSmall}' 'Stockfish/src/${nnueSmallFile}'
    cp -v '${nnueSmall}' 'Fairy-Stockfish/src/${nnueSmallFile}'
  '';

  useFetchCargoVendor = true;
  cargoHash = "sha256-aUSppXw0UDqCDX7YX+sYNEcmiABXDn0nrow0H9UjpaA=";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-${finalAttrs.pname}";

      runtimeInputs = [
        curl
        jq
        ripgrep
        common-updater-scripts
      ];

      text = ''
        new_fishnet_version="$(
          curl --silent https://api.github.com/repos/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/latest | \
            jq '.tag_name | ltrimstr("v")' --raw-output
        )"

        update-source-version "${finalAttrs.pname}" "$new_fishnet_version" --ignore-same-version --source-key="sources.fishnet" --print-changes

        stockfish_revision="$(curl --silent "https://api.github.com/repos/lichess-org/fishnet/contents/Stockfish?ref=v$new_fishnet_version" | jq .sha --raw-output)"

        stockfish_header="$(curl --silent "https://raw.githubusercontent.com/official-stockfish/Stockfish/$stockfish_revision/src/evaluate.h")"

        new_nnueBig_version="$(echo "$stockfish_header" | rg 'EvalFileDefaultNameBig "nn-(\w+).nnue"' --only-matching --replace '$1')"
        new_nnueBig_file="nn-''${new_nnueBig_version}.nnue"
        new_nnueBig_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url "https://tests.stockfishchess.org/api/nn/''${new_nnueBig_file}")")"

        sed -i package.nix \
            -e "s/${nnueBigFile}/''${new_nnueBig_file}/"
            -e "s/${nnueBig.hash}/''${new_nnueBig_hash}/"

        # new_nnueSmall_version="$(echo "$stockfish_header" | rg 'EvalFileDefaultNameSmall "nn-(\w+).nnue"' --only-matching --replace '$1')"

        # update-source-version '${finalAttrs.pname}.passthru.sources.nnueBig' "$new_nnueBig_version" --ignore-same-version --file=pkgs/by-name/fi/${finalAttrs.pname}/nnue.nix --print-changes

        # update-source-version '${finalAttrs.pname}.passthru.sources.nnueBig' "$new_nnueBig_version" --ignore-same-version --source-key="sources.nnueBig"

        # update-source-version '${finalAttrs.pname}.passthru.sources.nnueSmall' "$new_nnueSmall_version" --ignore-same-version --source-key="sources.nnueSmall"
      '';
    });
  };

  meta = with lib; {
    description = "Distributed Stockfish analysis for lichess.org";
    homepage = "https://github.com/lichess-org/fishnet";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      tu-maurice
      thibaultd
    ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "fishnet";
  };
})
