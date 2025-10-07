{
  lib,
  stdenvNoCC,
  buildGoModule,
  pkg-config,
  makeWrapper,
  libayatana-appindicator,
  gtk3,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "kanata-tray";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "rszyma";
    repo = "kanata-tray";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IR8mWt8pLBZ24+6xY8OBFRYAYLwcRKfbGTAE0bOcLuk=";
  };

  vendorHash = "sha256-tW8NszrttoohW4jExWxI1sNxRqR8PaDztplIYiDoOP8=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    makeWrapper
  ]
  ++ lib.optionals (stdenvNoCC.hostPlatform.isLinux) [
    libayatana-appindicator
    gtk3
  ];
  postInstall = ''
    wrapProgram $out/bin/kanata-tray --set KANATA_TRAY_LOG_DIR /tmp --prefix PATH : $out/bin
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.buildVersion=${finalAttrs.version}"
    "-X main.buildHash=unknown"
    "-X main.buildDate=unknown"
  ];

  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tray Icon for Kanata";
    longDescription = ''
      A simple wrapper for kanata to control it from tray icon.
    '';
    homepage = "https://github.com/rszyma/kanata-tray";
    license = lib.licenses.gpl3; # As specified in upstream... -or-later might be correct their intention?
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "kanata-tray";
    platforms = with lib.platforms; unix ++ windows;
  };
})
