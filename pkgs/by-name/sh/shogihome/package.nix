{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  electron_35,
  vulkan-loader,
  nix-update-script,
}:

let
  electron = electron_35;
in

buildNpmPackage (finalAttrs: {
  pname = "shogihome";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "sunfish-shogi";
    repo = "shogihome";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vVKdaFKOx4xm4BK+AjVr4cEDOHpOjOe58k2wUAhB9XA=";
  };

  npmDepsHash = "sha256-OS5DR+24F98ICgQ6zL4VD231Rd5JB/gJKl+qNfnP3PE=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = [ "--ignore-scripts" ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  env.npm_config_build_from_source = "true";
  nativeBuildInputs = [ makeWrapper ];

  makeCacheWritable = true;

  patches = [
    ./package-build-section.patch
    ./tslib.patch
  ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail 'npm run install:esbuild &&' ' ' \
      --replace-fail 'npm run install:electron &&' ' '
  '';

  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist
    rm electron-dist/libvulkan.so.1

    npm run electron:pack

    # ./node_modules/.bin/vite build

    # ./node_modules/.bin/tsc --project ./tsconfig.bg.json

    # ./node_modules/.bin/tsc-alias

    # ./node_modules/.bin/webpack --config-name preload

    # ./node_modules/.bin/webpack --config-name background

    ./node_modules/.bin/electron-builder \
        --dir \
        -c.electronDist=electron-dist \
        -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # https://github.com/NixOS/nixpkgs/pull/346215/files#diff-69d509716271021d88e077d5081f9e1f4098b7f684cfbb7cb5d64aec4cb167a6R218-R220
    # https://github.com/NixOS/nixpkgs/issues/346197#issuecomment-2392041000
    # rm -v $out/share/google/$appname/libvulkan.so.1
    # ln -v -s -t "$out/share/google/$appname" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"

    mkdir -p "$out/share/lib/shogihome"
    cp -r dist/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/shogihome"

    makeWrapper '${lib.getExe electron}' "$out/bin/shogihome" \
      --add-flags "$out/share/lib/shogihome/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  # NODE_OPTIONS = "--openssl-legacy-provider";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Shogi Frontend";
    homepage = "https://github.com/sunfish-shogi/shogihome";
    license = with lib.licenses; [
      mit
      asl20 # for icons
    ];
    maintainers = with lib.maintainers; [
      kachick
    ];
    mainProgram = "shogihome";
  };
})
