{
  lib,
  stdenvNoCC,
  fetchurl,
  # fetchzip,
  # fetchFromGitHub,
  jdk,
  jre,
  # zip,
  makeWrapper,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ludii";
  version = "1.3.14";

  # src = fetchFromGitHub {
  #   owner = "Ludeme";
  #   repo = "Ludii";
  #   tag = "v${finalAttrs.version}";
  #   hash = "sha256-hw7UuzesqpmnTjgpfikAIYyY70ni7BxjaUtHAPEdkXI=";
  # };

  # Preffering official release assets because of GitHub repository does not have versioned tags.
  # ref: https://github.com/Ludeme/Ludii
  src = fetchurl {
    url = "https://ludii.games/downloads/Ludii-${finalAttrs.version}.jar";
    hash = "sha256-JIqL3oAfNHvDgKSVf9tIAStL3yNKVZHJv3R5kT1zBo4=";
  };

  nativeBuildInputs = [
    jdk
    # zip
    makeWrapper
  ];

  # sourceRoot = "${finalAttrs.src.name}/main/java/BitsNPicas";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/java"
    mkdir -p "$out/bin"

    install -Dm444 "$src" "$out/share/java/Ludii.jar"

    makeWrapper "${jre}/bin/java" "$out/bin/Ludii" \
      --add-flags "-jar $out/share/java/Ludii.jar"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    help="$("$out/bin/Ludii" --help)"
    [[ "$help" == *"Show this help message"* ]]

    runHook postInstallCheck
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "General game system";
    homepage = "http://ludii.games";
    license = lib.licenses.cc-by-nc-nd-40;
    mainProgram = "Ludii";
    maintainers = with lib.maintainers; [
      kachick
    ];
    platforms = lib.platforms.all;
  };
})
