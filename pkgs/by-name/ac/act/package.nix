{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "0.2.69";
in
buildGoModule {
  pname = "act";
  inherit version;

  src = fetchFromGitHub {
    owner = "nektos";
    repo = "act";
    rev = "refs/tags/v${version}";
    hash = "sha256-Aqs6mIP4pJm0ynExMsmSh3CCtgZY1H3er3ZoXggHOk0=";
  };

  vendorHash = "sha256-VZbzyGb9DI3O5IoNtBneiziY7zPF3mlrDqRlBUPsdEM=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "Run your GitHub Actions locally";
    mainProgram = "act";
    homepage = "https://github.com/nektos/act";
    changelog = "https://github.com/nektos/act/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      Br1ght0ne
      kashw2
    ];
  };
}
