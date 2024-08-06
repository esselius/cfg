#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash jq nix git coreutils

set -euo pipefail

flake-store-dir() {
  nix flake metadata --json | jq -r .path | sed -E 's|/nix/store/(.*)|\1|'
}

evaled-files() {
  local dir="$(flake-store-dir)"

  nix path-info --derivation "$1" -vv 2>&1 | grep "${dir}" | grep 'evaluating file' | sed -E "s|evaluating file '/nix/store/.*${dir}/(.*)'|\1|"
}

md5-list() {
  sort | xargs md5sum 
}

main() {
  evaled-files "$1" | md5-list
}

main "$@"
