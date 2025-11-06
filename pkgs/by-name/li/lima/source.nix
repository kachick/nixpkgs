{
  fetchFromGitHub,
}:

let
  version = "2.0.0";
in
{
  inherit version;

  src = fetchFromGitHub {
    owner = "lima-vm";
    repo = "lima";
    tag = "v${version}";
    hash = "sha256-X0MyXcgi63HEh+0DF/mt50z2vVsz/ENs9T4rsjZhjYw=";
  };

  vendorHash = "sha256-dA6zdrhN73Y8InlrCEdHgYwe5xbUlvKx0IMis2nWgWE=";
}
