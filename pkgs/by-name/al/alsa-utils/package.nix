{
  lib,
  stdenv,
  directoryListingUpdater,
  fetchurl,
  alsa-lib,
  alsa-plugins,
  gettext,
  makeWrapper,
  ncurses,
  libsamplerate,
  pciutils,
  procps,
  which,
  fftw,
  pipewire,
  withPipewireLib ? true,
  symlinkJoin,
}:

let
  plugin-packages = [ alsa-plugins ] ++ lib.optional withPipewireLib pipewire;

  # Create a directory containing symlinks of all ALSA plugins.
  # This is necessary because ALSA_PLUGIN_DIR must reference only one directory.
  plugin-dir = symlinkJoin {
    name = "all-plugins";
    paths = map (path: "${path}/lib/alsa-lib") plugin-packages;
  };
in
stdenv.mkDerivation rec {
  pname = "alsa-utils";
  version = "1.2.13";

  src = fetchurl {
    url = "mirror://alsa/utils/alsa-utils-${version}.tar.bz2";
    hash = "sha256-FwKmsc35uj6ZbsvB3c+RceaAj1lh1QPQ8n6A7hYvHao=";
  };

  nativeBuildInputs = [
    gettext
    makeWrapper
  ];
  buildInputs = [
    alsa-lib
    ncurses
    libsamplerate
    fftw
  ];

  configureFlags = [
    "--disable-xmlto"
    "--with-udev-rules-dir=$(out)/lib/udev/rules.d"
  ];

  installFlags = [ "ASOUND_STATE_DIR=$(TMPDIR)/dummy" ];

  postFixup = ''
    mv $out/bin/alsa-info.sh $out/bin/alsa-info
    wrapProgram $out/bin/alsa-info --prefix PATH : "${
      lib.makeBinPath [
        which
        pciutils
        procps
      ]
    }"
    wrapProgram $out/bin/aplay --set-default ALSA_PLUGIN_DIR ${plugin-dir}
  '';

  postInstall = ''
    # udev rules are super broken, violating `udevadm verify` in various creative ways.
    # NixOS has its own set of alsa udev rules, we can just delete the udev rules for this package
    rm -rf $out/lib/udev
  '';

  passthru.updateScript = directoryListingUpdater {
    url = "https://www.alsa-project.org/files/pub/utils/";
  };

  meta = with lib; {
    homepage = "http://www.alsa-project.org/";
    description = "ALSA, the Advanced Linux Sound Architecture utils";
    longDescription = ''
      The Advanced Linux Sound Architecture (ALSA) provides audio and
      MIDI functionality to the Linux-based operating system.
    '';

    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
