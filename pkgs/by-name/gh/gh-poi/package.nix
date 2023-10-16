{ lib
, buildGo119Module
, fetchFromGitHub
}:

let
  pname = "gh-poi";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "seachicken";
    repo = "gh-poi";
    rev = "v${version}";
    hash = "sha256-wSyKTi/OAq/+tS1STmGa3QMrzyyBh/Q01xY0qPtHJdc=";
  };
in
buildGo119Module {
  inherit pname version src;

  vendorHash = "sha256-D/YZLwwGJWCekq9mpfCECzJyJ/xSlg7fC6leJh+e8i0=";

  # tests require network access
  doCheck = false;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Safely clean up your local branches";
    homepage = "https://github.com/seachicken/gh-poi";
    changelog = "https://github.com/seachicken/gh-poi/releases/tag/${src.rev}";
    license = licenses.mit;
    maintainers = with maintainers; [ kachick ];
    mainProgram = "gh-poi";
  };
}
