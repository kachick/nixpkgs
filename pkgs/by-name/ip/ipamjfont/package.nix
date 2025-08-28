{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ipamjfont";
  version = "006.01";

  src =
    let
      suffix = lib.strings.replaceString "." "" finalAttrs.version;
    in
    fetchzip {
      url = "https://dforest.watch.impress.co.jp/library/i/ipamjfont/10750/ipamjm${suffix}.zip";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      stripRoot = false;
    };

  installPhase = ''
    runHook preInstall

    install -Dm444 *.ttf -t "$out/share/fonts/truetype/"

    runHook postInstall
  '';

  meta = {
    description = "Japanese font package with Mincho fonts";
    downloadPage = "https://forest.watch.impress.co.jp/library/software/ipamjfont/";
    homepage = "https://moji.or.jp/mojikiban/font/";
    license = lib.licenses.ipa;
    maintainers = with lib.maintainers; [
      kachick
    ];
  };
})
