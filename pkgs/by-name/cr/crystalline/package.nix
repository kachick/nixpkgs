{
  lib,
  crystal_1_16,
  fetchFromGitHub,
  llvmPackages ? crystal_1_16.llvmPackages,
  openssl,
  shards,
  makeWrapper,
  _experimental-update-script-combinators,
  crystal2nix,
  runCommand,
  writeShellApplication,
  writeShellScript,
  gitUpdater,
  nix,
  gnugrep,
  gnused,
  testers,
  crystalline,
}:

let
  version = "0.17.1";
  crystal = crystal_1_16;
in
crystal.buildCrystalPackage rec {
  pname = "crystalline";
  inherit version;

  src = fetchFromGitHub {
    owner = "elbywan";
    repo = "crystalline";
    rev = "v${version}";
    hash = "sha256-SIfInDY6KhEwEPZckgobOrpKXBDDd0KhQt/IjdGBhWo=";
  };

  format = "crystal";
  shardsFile = ./shards.nix;

  nativeBuildInputs = [
    llvmPackages.llvm
    openssl
    makeWrapper
    shards
  ];

  doCheck = false;
  doInstallCheck = false;

  crystalBinaries.crystalline = {
    src = "src/crystalline.cr";
    options = [
      "--release"
      "--no-debug"
      "--progress"
      "-Dpreview_mt"
    ];
  };

  postInstall = ''
    wrapProgram "$out/bin/crystalline" --prefix PATH : '${lib.makeBinPath [ llvmPackages.llvm.dev ]}'
  '';

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater { rev-prefix = "v"; })
      (lib.getExe (writeShellApplication {
        name = "${pname}-crystal-updater";
        runtimeInputs = [
          nix
          gnugrep
          gnused
        ];
        runtimeEnv = {
          PNAME = pname;
          PKG_FILE = builtins.toString ./package.nix;
        };
        text = ''
          new_src="$(nix-build --attr "pkgs.$PNAME.src" --no-out-link)"
          new_crystal_minor="$(grep --perl-regexp --only-matching '^FROM crystallang/crystal:[1-9]\.\K[0-9]+' "$new_src/Dockerfile")"
          sed -i -E "s/crystal_1_[0-9]+/electron_1_$new_crystal_minor/g" "$PKG_FILE"
        '';
      }))
      (_experimental-update-script-combinators.copyAttrOutputToFile "crystalline.shardLock" "${builtins.toString ./.}/shard.lock")
      {
        command = [
          (writeShellScript "update-lock" "cd $1; ${lib.getExe crystal2nix}")
          ./.
        ];
        supportedFeatures = [ "silent" ];
      }
      {
        command = [
          "rm"
          "${builtins.toString ./.}/shard.lock"
        ];
        supportedFeatures = [ "silent" ];
      }
    ];
    shardLock = runCommand "shard.lock" { inherit src; } ''
      cp $src/shard.lock $out
    '';

    # Since doInstallCheck causes another test error, versionCheckHook is avoided.
    tests.version = testers.testVersion {
      package = crystalline;
    };
  };

  meta = with lib; {
    description = "Language Server Protocol implementation for Crystal";
    mainProgram = "crystalline";
    homepage = "https://github.com/elbywan/crystalline";
    license = licenses.mit;
    maintainers = with maintainers; [ donovanglover ];
  };
}
