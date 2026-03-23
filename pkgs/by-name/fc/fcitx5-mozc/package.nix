{
  lib,
  callPackage,
  bazel_8,
  fcitx5,
  fetchFromGitHub,
  gettext,
  mozc,
  nixosTests,
  pkg-config,
  protobuf_32,
  python3,
  stdenv,
  unzip,
  libxcrypt,
  libGL,
}:

let
  bazelPackage = callPackage ../../ba/bazel_8/build-support/bazelPackage.nix { };
  registry = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-central-registry";
    rev = "722299976c97e5191045c8016b7c8532189fc3f6";
    sha256 = "sha256-hi5BKI94am2LCXD93GBeT0gsODxGeSsd0OrhTwpNAgM=";
  };
in
bazelPackage rec {
  pname = "fcitx5-mozc";
  version = "2.31.5600.102";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = "mozc";
    fetchSubmodules = true;
    rev = "96fcec5b1a2023b50eaec52e7a14ea10e11f5542";
    hash = "sha256-eDKPolRE4xoyWM8bbk0j4hXcRHR3/0uhV9z9BEWQnq8=";
  };

  inherit registry;
  bazel = bazel_8;

  nativeBuildInputs = [
    gettext
    pkg-config
    python3
    unzip
    libGL
  ];

  buildInputs = [
    mozc
    fcitx5
    libxcrypt
    libGL
  ];

  env = {
    USE_BAZEL_VERSION = bazel_8.version;
  };

  targets = [
    "unix/fcitx5:fcitx5-mozc.so"
    "unix/icons"
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

    substituteInPlace bazel/pkg_config_repository.bzl \
      --replace-fail '"--libs-only-l"' '"--libs"'

    sed -i -e 's|^\(LINUX_MOZC_SERVER_DIR = \).\+|\1"${mozc}/lib/mozc"|' config.bzl
  '';

  sourceRoot = "source/src";

  installPhase = ''
    runHook preInstall

    install -Dm444 ../LICENSE $out/share/licenses/fcitx5-mozc/LICENSE
    install -Dm444 data/installer/credits_en.html $out/share/licenses/fcitx5-mozc/Submodules

    install -Dm555 bazel-bin/unix/fcitx5/fcitx5-mozc.so $out/lib/fcitx5/fcitx5-mozc.so
    install -Dm444 unix/fcitx5/mozc-addon.conf $out/share/fcitx5/addon/mozc.conf
    install -Dm444 unix/fcitx5/mozc.conf $out/share/fcitx5/inputmethod/mozc.conf

    for pofile in unix/fcitx5/po/*.po; do
      filename=$(basename $pofile)
      lang=''${filename/.po/}
      mofile=''${pofile/.po/.mo}
      msgfmt $pofile -o $mofile
      install -Dm444 $mofile $out/share/locale/$lang/LC_MESSAGES/fcitx5-mozc.mo
    done

    msgfmt --xml -d unix/fcitx5/po/ --template unix/fcitx5/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml.in -o unix/fcitx5/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml
    install -Dm444 unix/fcitx5/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml $out/share/metainfo/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml

    cd bazel-bin/unix

    unzip -o icons.zip

    install -Dm444 mozc.png $out/share/icons/hicolor/128x128/apps/org.fcitx.Fcitx5.fcitx_mozc.png
    ln -s org.fcitx.Fcitx5.fcitx_mozc.png $out/share/icons/hicolor/128x128/apps/fcitx_mozc.png

    for svg in \
      alpha_full.svg \
      alpha_half.svg \
      direct.svg \
      hiragana.svg \
      katakana_full.svg \
      katakana_half.svg \
      outlined/dictionary.svg \
      outlined/properties.svg \
      outlined/tool.svg
    do
      name=$(basename -- $svg)
      path=$out/share/icons/hicolor/scalable/apps
      prefix=org.fcitx.Fcitx5.fcitx_mozc

      install -Dm444 $svg $path/$prefix_$name
      ln -s $prefix_$name $path/fcitx_mozc_$name
    done

    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [
    "libcrypt.so.1"
  ];

  bazelVendorDepsFOD = {
    outputHash = lib.fakeHash;
    outputHashAlgo = "sha256";
  };

  passthru.tests = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    inherit (nixosTests) fcitx5;
  };

  meta = {
    description = "Mozc - a Japanese Input Method Editor designed for multi-platform";
    homepage = "https://github.com/fcitx/mozc";
    license = with lib.licenses; [
      asl20 # abseil-cpp
      bsd3 # mozc, breakpad, gtest, gyp, japanese-usage-dictionary, protobuf
      mit # wil
      naist-2003 # IPAdic
      publicDomain # src/data/test/stress_test, Okinawa dictionary
      unicode-30 # src/data/unicode, breakpad
    ];
    maintainers = with lib.maintainers; [
      berberman
      govanify
      musjj
    ];
    platforms = lib.platforms.linux;
  };
}
