new_version="$(
	curl --silent "https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest" |
		jq '.tag_name | ltrimstr("v")' --raw-output
)"
stockfish_revision="$(curl --silent "https://api.github.com/repos/lichess-org/fishnet/contents/Stockfish?ref=v$new_version" | jq .sha --raw-output)"
stockfish_header="$(curl --silent "https://raw.githubusercontent.com/official-stockfish/Stockfish/$stockfish_revision/src/evaluate.h")"
new_nnue_big_file="$(echo "$stockfish_header" | grep --perl-regexp --only-matching 'EvalFileDefaultNameBig "\Knn-(\w+).nnue')"
new_nnue_big_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://tests.stockfishchess.org/api/nn/${new_nnue_big_file}")")"
new_nnue_small_file="$(echo "$stockfish_header" | grep --perl-regexp --only-matching 'EvalFileDefaultNameSmall "\Knn-(\w+).nnue')"
new_nnue_small_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://tests.stockfishchess.org/api/nn/${new_nnue_small_file}")")"

update-source-version "$PNAME" "$new_version" --ignore-same-version --print-changes

pkg_body="$(<"$PKG_FILE")"
pkg_body="${pkg_body//"$NNUE_BIG_FILE"/"$new_nnue_big_file"}"
pkg_body="${pkg_body//"$NNUE_BIG_HASH"/"$new_nnue_big_hash"}"
pkg_body="${pkg_body//"$NNUE_SMALL_FILE"/"$new_nnue_small_file"}"
pkg_body="${pkg_body//"$NNUE_SMALL_HASH"/"$new_nnue_small_hash"}"
echo "$pkg_body" >"$PKG_FILE"
