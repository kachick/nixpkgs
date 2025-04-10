new_fishnet_version="$(
    curl --silent "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" | \
    jq '.tag_name | ltrimstr("v")' --raw-output
)"

stockfish_revision="$(curl --silent "https://api.github.com/repos/lichess-org/fishnet/contents/Stockfish?ref=v$new_fishnet_version" | jq .sha --raw-output)"
stockfish_header="$(curl --silent "https://raw.githubusercontent.com/official-stockfish/Stockfish/$stockfish_revision/src/evaluate.h")"

new_nnueBig_version="$(echo "$stockfish_header" | rg 'EvalFileDefaultNameBig "nn-(\w+).nnue"' --only-matching --replace '$1')"
new_nnueBig_file="nn-${new_nnueBig_version}.nnue"
new_nnueBig_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://tests.stockfishchess.org/api/nn/${new_nnueBig_file}")")"

update-source-version "$PNAME" "$new_fishnet_version" --ignore-same-version --print-changes

sd --string-mode "$NNUE_BIG_FILE" "$new_nnueBig_file" "$PFILE"
sd --string-mode "$NNUE_BIG_HASH" "$new_nnueBig_hash" "$PFILE"

# new_nnueSmall_version="$(echo "$stockfish_header" | rg 'EvalFileDefaultNameSmall "nn-(\w+).nnue"' --only-matching --replace '$1')"

# update-source-version '${finalAttrs.pname}.passthru.sources.nnueBig' "$new_nnueBig_version" --ignore-same-version --file=pkgs/by-name/fi/${finalAttrs.pname}/nnue.nix --print-changes

# update-source-version '${finalAttrs.pname}.passthru.sources.nnueBig' "$new_nnueBig_version" --ignore-same-version --source-key="sources.nnueBig"

# update-source-version '${finalAttrs.pname}.passthru.sources.nnueSmall' "$new_nnueSmall_version" --ignore-same-version --source-key="sources.nnueSmall"
