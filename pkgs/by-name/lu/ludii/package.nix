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
  makeDesktopItem,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ludii";
  version = "1.3.14";

  # Preffering official release assets
  # - GitHub repository does not have versioned tags. ref: https://github.com/Ludeme/Ludii/tags
  # - ludii.games providing Ludii*-src.jar does not have same structure as GitHub repository. At least, there is no PlayerDesktop/build.xml
  src = fetchurl {
    url = "https://ludii.games/downloads/Ludii-${finalAttrs.version}.jar";
    hash = "sha256-JIqL3oAfNHvDgKSVf9tIAStL3yNKVZHJv3R5kT1zBo4=";
  };

  nativeBuildInputs = [
    jdk
    makeWrapper
  ];

  dontUnpack = true;

  postUnpack = ''
    "${jdk}/bin/jar" xf "$src"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"

    install -Dm444 "$src" "$out/share/java/Ludii.jar"
    install -Dm444 ludii-logo-64x64.png "$out/share/icons/hicolor/128x128/apps/ludii.png"

    makeWrapper "${jre}/bin/java" "$out/bin/Ludii" \
      --add-flags "-jar $out/share/java/Ludii.jar"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Ludii";
      genericName = "Ludii";
      desktopName = "Ludii";
      comment = "General game system";
      icon = "ludii";
      exec = "Ludii";
      categories = [ "Game" ];
    })
  ];

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
