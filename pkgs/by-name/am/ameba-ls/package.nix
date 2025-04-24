{
  lib,
  fetchFromGitHub,
  crystal,
  unstableGitUpdater,
# coreutils,
}:

crystal.buildCrystalPackage {
  pname = "ameba-ls";
  version = "unstable-2025-03-16";

  src = fetchFromGitHub {
    owner = "crystal-lang-tools";
    repo = "ameba-ls";
    rev = "5e52ab9e797829b64c44ed3738c3ee91c7e3f3b8";
    hash = "sha256-wQcTGs8ifftbAfy+807jnaSSd0tM9s2+GYsIIdAzRdU=";
  };

  # format = "make";
  shardsFile = ./shards.nix;
  # installFlags = [ "INSTALL_BIN=${coreutils}/bin/install" ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Language server for the Ameba linter for Crystal language";
    mainProgram = "ameba-ls";
    homepage = "https://github.com/crystal-lang-tools/ameba-ls";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      kachick
    ];
  };
}
