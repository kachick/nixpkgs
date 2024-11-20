{ lib
, rustPlatform
, fetchCrate
}:

rustPlatform.buildRustPackage rec {
  pname = "killport";
  version = "1.1.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-7bENyg/KR4oI//jvG6bw+3UX3j9ITAXCMTpc+65VBZ8=";
  };

  cargoHash = "sha256-KKlY1c70wYaEgYQGveUf4mfYuZ81fAQHVANKniw4nL4=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  preCheck = ''
    export RUST_BACKTRACE=full
  '';

  # checkFlags = [
  #   # assertion failed: re.is_match(data)
  #   "--skip=tests::test_dry_run_option"
  #   "--skip=tests::test_basic_kill_process"
  #   "--skip=tests::test_signal_handling"
  #   "--skip=tests::test_mode_option"
  # ];

  meta = with lib; {
    description = "Command-line tool to easily kill processes running on a specified port";
    homepage = "https://github.com/jkfran/killport";
    license = licenses.mit;
    maintainers = with maintainers; [ sno2wman ];
    mainProgram = "killport";
  };
}
