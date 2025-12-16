{
  lib,
  rustPlatform,
  fetchCrate,
  installShellFiles,
}:

rustPlatform.buildRustPackage rec {
  pname = "scraper";
  version = "0.25.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-lO1dfGEzeO2iSdtqfj30lF/fXBkLvEWkVfabBjlJ3+Q=";
  };

  cargoHash = "sha256-vbJMOVur2QE0rFo1OJkSsuNzTOzn22ty5Py3gozDEzs=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage scraper.1
  '';

  meta = {
    description = "Tool to query HTML files with CSS selectors";
    mainProgram = "scraper";
    homepage = "https://github.com/causal-agent/scraper";
    changelog = "https://github.com/causal-agent/scraper/releases/tag/v${version}";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
}
