{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ipamjm";
  version = "006";
  revision = "01";

  src = fetchzip {
    url = "https://dforest.watch.impress.co.jp/library/i/ipamjfont/10750/ipamjm${finalAttrs.version}${finalAttrs.revision}.zip";
    hash = "";
  };

  installPhase = ''
    runHook preInstall

    install -Dm444 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Japanese Mincho font requiring precise character variants";
    homepage = "https://moji.or.jp/mojikiban/font/";
    license = licenses.ipa;
    platforms = platforms.all;
    maintainers = with maintainers; [
      kachick
    ];
  };
})
