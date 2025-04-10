new_fishnet_version="$(
	curl --silent "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" |
		jq '.tag_name | ltrimstr("v")' --raw-output
)"

stockfish_revision="$(curl --silent "https://api.github.com/repos/lichess-org/fishnet/contents/Stockfish?ref=v$new_fishnet_version" | jq .sha --raw-output)"
stockfish_header="$(curl --silent "https://raw.githubusercontent.com/official-stockfish/Stockfish/$stockfish_revision/src/evaluate.h")"

new_nnueBig_version="$(echo "$stockfish_header" | grep --perl-regexp --only-matching 'EvalFileDefaultNameBig "\Knn-(\w+).nnue')"
new_nnueBig_file="nn-${new_nnueBig_version}.nnue"
new_nnueBig_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://tests.stockfishchess.org/api/nn/${new_nnueBig_file}")")"
new_nnueSmall_version="$(echo "$stockfish_header" | grep --perl-regexp --only-matching 'EvalFileDefaultNameSmall "\Knn-(\w+).nnue')"
new_nnueSmall_file="nn-${new_nnueSmall_version}.nnue"
new_nnueSmall_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://tests.stockfishchess.org/api/nn/${new_nnueSmall_file}")")"

update-source-version "$PNAME" "$new_fishnet_version" --ignore-same-version --print-changes

pfile_content="$(cat "$PFILE")"
pfile_content="${pfile_content//"$NNUE_BIG_FILE"/"$new_nnueBig_file"}"
pfile_content="${pfile_content//"$NNUE_BIG_HASH"/"$new_nnueBig_hash"}"
pfile_content="${pfile_content//"$NNUE_SMALL_FILE"/"$new_nnueSmall_file"}"
pfile_content="${pfile_content//"$NNUE_SMALL_HASH"/"$new_nnueSmall_hash"}"
echo "$pfile_content" >"$PFILE"
