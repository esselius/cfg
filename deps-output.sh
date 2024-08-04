#!/usr/bin/env bash

set -x

flake-store-dir() {
  nix flake metadata --json | jq -r .path | sed -E 's|/nix/store/(.*)|\1|'
}

evaled-files() {
  nix path-info --derivation "$1" --no-eval-cache -vv 2>&1 | grep "$2" | grep 'evaluating file' | sed -E "s|evaluating file '/nix/store/.*$2/(.*)'|\1|"
}

md5-list() {
  sort | xargs md5sum 
}

main() {
  local store_dir="$(flake-store-dir)"
  local nix_files="$(evaled-files .#nixosTests.monitoring-auth "${store_dir}")"
  md5-list <<< "${nix_files}"
}

main "$@"
