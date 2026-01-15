{
  lib,
  buildGo125Module,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  nix-update-script,
  writeShellApplication,
  gnugrep,
  common-updater-scripts,
}:

let
  buildGoModule = buildGo125Module;
in
buildGoModule (finalAttrs: {
  pname = "typescript-go";
  version = "0-unstable-2026-01-14";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "typescript-go";
    rev = "f5bcdfc02e6527b774418a26ee817c4397da8546";
    hash = "sha256-tNpRCXj/QoYP2uw7nWaQZAnQtktYgVfZZ1/L+N+/xys=";
    fetchSubmodules = false;
  };

  vendorHash = "sha256-1uZemqPsDxiYRVjLlC/UUP4ZXVCjocIBCj9uCzQHmog=";

  ldflags = [
    "-s"
    "-w"
  ];

  env.CGO_ENABLED = 0;

  subPackages = [
    "cmd/tsgo"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    version="$("$out/bin/tsgo" --version)"
    [[ "$version" == *"7.0.0"* ]]

    runHook postInstallCheck
  '';

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        extraArgs = [ "--version=branch" ];
      })

      (lib.getExe (writeShellApplication {
        name = "${finalAttrs.pname}-update-script";

        runtimeInputs = [
          # curl
          # jq
          common-updater-scripts
          gnugrep
        ];

        text = ''
          new_major_minor="$(grep --only-matching --perl-regexp '(?<=var version =").*(?=")' '${finalAttrs.src}/internal/core/version.go')"
          suffix="$(grep '(-unstable-[0-9-]+)' --only-matching --perl-regexp  <<< '${finalAttrs.version}')"
          update-source-version '${finalAttrs.pname}' "$new_major_minor$suffix"
          # sed -i -E "s/${finalAttrs.version}/$new_version/g" '${./package.nix}'
        '';
      }))
    ];
  };

  # passthru = {
  #   updateScript = lib.getExe (writeShellApplication {
  #     name = "lichess-bot-update-script";

  #     runtimeInputs = [
  #       curl
  #       jq
  #       common-updater-scripts
  #     ];

  #     text = ''
  #       commit_msg='^Auto update version to (?<ver>[0-9.]+)$'
  #       commit="$(
  #         curl -s 'https://api.github.com/repos/lichess-bot-devs/lichess-bot/commits?path=lib/versioning.yml' | \
  #         jq -c "map(select(.commit.message | test(\"$commit_msg\"))) | first"
  #       )"
  #       rev="$(jq -r '.sha' <<< "$commit")"
  #       version="$(jq -r ".commit.message | capture(\"$commit_msg\") | .ver" <<< "$commit")"

  #       update-source-version lichess-bot "$version" --rev="$rev"
  #     '';
  #   });
  # };

  meta = {
    description = "Go implementation of TypeScript";
    homepage = "https://github.com/microsoft/typescript-go";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "tsgo";
  };
})
