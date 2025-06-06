{
  lib,
  stdenvNoCC,
  fetchurl,
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

  # GitHub repository https://github.com/Ludeme/Ludii/ does not have versioned tags.
  src = fetchurl {
    url = "https://ludii.games/downloads/Ludii-${finalAttrs.version}-src.jar";
    hash = lib.fakeHash;
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

    # mkdir -p $out/share/java
    # mkdir -p $out/bin
    install -Dm444 "$src" "$out/share/java/"
    makeWrapper "${jre}/bin/java" $out/bin/bfg --add-flags "-cp $out/share/java/$jarName com.madgag.git.bfg.cli.Main"

    makeWrapper "${jre}/bin/java" "$out/bin/Ludii" \
      --add-flags "-jar $out/share/java/Ludii.jar"

    runHook postInstall
  '';

  # doInstallCheck = true;
  # installCheckPhase = ''
  #   runHook preInstallCheck

  #   "$out/bin/bitsnpicas" convertbitmap -f psf "${spleen}/share/fonts/misc/spleen-8x16.bdf"
  #   [[ -f Spleen.psf ]]

  #   runHook postInstallCheck
  # '';

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
