{
  lib,
  callPackage,
  bazel_8,
  fetchFromGitHub,
  qt6,
  pkg-config,
  protobuf_32,
  libxcrypt,
  libGL,
  ibus,
  withIbus ? false,
  unzip,
  python3,
  xdg-utils,
  jp-zip-codes,
  dictionaries ? [ ],
  merge-ut-dictionaries,
}:

let
  ut-dictionary = merge-ut-dictionaries.override { inherit dictionaries; };
  bazelPackage = callPackage ../../ba/bazel_8/build-support/bazelPackage.nix { };
  registry = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-central-registry";
    rev = "722299976c97e5191045c8016b7c8532189fc3f6";
    sha256 = "sha256-hi5BKI94am2LCXD93GBeT0gsODxGeSsd0OrhTwpNAgM=";
  };
in
bazelPackage rec {
  pname = "mozc";
  version = "2.32.5994.102";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "google";
    repo = "mozc";
    rev = "d9c3f195582de6b0baa07ecb81a04e8902acf9af";
    hash = "sha256-1FBGWHxPmpqVVWGQ7u1VFzaviHu8lt+866LjIk0Tx+8=";
    fetchSubmodules = true;
  };

  inherit registry;
  bazel = bazel_8;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    pkg-config
    unzip
    python3
    libGL
  ];

  buildInputs = [
    qt6.qtbase
    libxcrypt
    libGL
  ]
  ++ lib.optional withIbus ibus;

  env = {
    USE_BAZEL_VERSION = bazel_8.version;
  };

  targets = [
    "unix/icons"
    "gui/tool:mozc_tool"
    "server:mozc_server"
    "unix/emacs:mozc_emacs_helper"
    "unix/emacs:mozc.el"
    "renderer/qt:mozc_renderer"
  ]
  ++ lib.optionals withIbus [
    "unix/ibus:gen_mozc_xml"
    "unix/ibus:ibus_mozc"
  ];

  commandArgs = [
    "--config=oss_linux"
    "--compilation_mode=opt"
    "--action_env=PATH"
  ];

  postPatch = ''
    # replace protobuf with our own
    cat >> MODULE.bazel <<EOF
local_path_override(
    module_name = "protobuf",
    path = "third_party/protobuf",
)
EOF
    mkdir -p third_party/protobuf
    cp -r ${protobuf_32.src}/* third_party/protobuf/
    # Copy hidden files like MODULE.bazel
    cp ${protobuf_32.src}/MODULE.bazel third_party/protobuf/ || true
    cp ${protobuf_32.src}/WORKSPACE third_party/protobuf/ || true
    chmod -R +w third_party/protobuf

    substituteInPlace config.bzl \
      --replace-fail "/usr/bin/xdg-open" "${xdg-utils}/bin/xdg-open" \
      --replace-fail "/usr" "$out"

    substituteInPlace bazel/pkg_config_repository.bzl \
      --replace-fail '"--libs-only-l"' '"--libs"'

    substituteInPlace MODULE.bazel \
      --replace-fail "https://github.com/hiroyuki-komatsu/japanpost_zipcode/raw/33524763837473258e7ba2f14b17fc3a70519831/ken_all.zip" "file://${jp-zip-codes}/ken_all.zip" \
      --replace-fail "https://github.com/hiroyuki-komatsu/japanpost_zipcode/raw/33524763837473258e7ba2f14b17fc3a70519831/jigyosyo.zip" "file://${jp-zip-codes}/jigyosyo.zip"

    # Remove sha256 from zip_code_jigyosyo and zip_code_ken_all
    # They are around the URLs we just replaced.
    # We can use sed to remove lines starting with sha256 = around those.
    # Actually, let's just use replace-fail for the specific hashes.
    substituteInPlace MODULE.bazel \
      --replace-fail "sha256 = \"8b0c5e9f720dba6d600a2683a260b8f04d14f463d45d10893e7ba08424405a1e\"," "" \
      --replace-fail "sha256 = \"47a3e63e1379f707af9c49df5c4fa0534332173c73c61f93d14555673bed7599\"," "" \
      --replace-fail '"Qt6Widgets",' '"Qt6Widgets", "gl",'
  '';

  sourceRoot = "source/src";

  bazelPreBuild = ''
    ${lib.optionalString (dictionaries != [ ]) ''
      cat ${ut-dictionary}/mozcdic-ut.txt >> data/dictionary_oss/dictionary00.txt
    ''}
  '';

  installPhase = ''
    runHook preInstall

    install -Dm555 "bazel-bin/server/mozc_server"           "$out/lib/mozc/mozc_server"
    install -Dm555 "bazel-bin/renderer/qt/mozc_renderer"    "$out/lib/mozc/mozc_renderer"
    install -Dm555 "bazel-bin/gui/tool/mozc_tool"           "$out/lib/mozc/mozc_tool"
    install -Dm555 "bazel-bin/unix/emacs/mozc_emacs_helper" "$out/bin/mozc_emacs_helper"
    install -Dm444 "unix/emacs/mozc.el"                     "$out/share/emacs/site-lisp/emacs-mozc/mozc.el"
    install -d "$out/share/icons/mozc/"
    unzip bazel-bin/unix/icons.zip -d "$out/share/icons/mozc/"
  ''
  + (lib.optionalString withIbus ''
    install -Dm555 "bazel-bin/unix/ibus/ibus_mozc"          "$out/lib/ibus-mozc/ibus-engine-mozc"
    install -Dm555 "bazel-bin/unix/ibus/mozc.xml"           "$out/share/ibus/components/mozc.xml"
    install -d "$out/share/icons/ibus-mozc/"
    for icon in $out/share/icons/mozc/*.png
    do
      cp $icon $out/share/icons/ibus-mozc/
    done
    mv $out/share/icons/ibus-mozc/{mozc,product_icon}.png
  '')
  + ''
    mkdir -p $out/share/applications
    cp ${./ibus-setup-mozc-jp.desktop} $out/share/applications/ibus-setup-mozc-jp.desktop
    substituteInPlace $out/share/applications/ibus-setup-mozc-jp.desktop \
      --replace-fail "@mozc@" "$out"

    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [
    "libcrypt.so.1"
  ];

  bazelVendorDepsFOD = {
    outputHash = "sha256-nfM2s8VcvP61TiHyhRuJOsVbcFdWFYMu67rbUQsuuC0=";
    outputHashAlgo = "sha256";
  };

  meta = {
    isIbusEngine = withIbus;
    description = "Japanese input method from Google";
    mainProgram = "mozc_emacs_helper";
    homepage = "https://github.com/google/mozc";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      pineapplehunter
    ];
  };
}
