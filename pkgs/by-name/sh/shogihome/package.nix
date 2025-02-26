{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "shogihome";
  version = "1.21.1";

  src = fetchFromGitHub {
    owner = "sunfish-shogi";
    repo = "shogihome";
    tag = "v${version}";
    hash = "sha256-zKtNhzrTrz4cLMraRbGREN8e4VUpzzJ6bIkk+XI9F00=";
  };

  npmDepsHash = lib.fakeHash;

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  # NODE_OPTIONS = "--openssl-legacy-provider";

  meta = {
    description = "Shogi Frontend";
    homepage = "https://github.com/sunfish-shogi/shogihome";
    license = with lib.licenses; [
      mit
      asl20 # for icons
    ];
    maintainers = with lib.maintainers; [ kachick ];
    mainProgram = "shogihome";
    platforms = lib.platforms.all;
  };
}
