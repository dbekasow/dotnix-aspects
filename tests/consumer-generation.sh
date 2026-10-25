#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d "${TMPDIR:-/tmp}/dotnix-consumer-generation.XXXXXX")"
consumer="$tmp/consumer"
trap 'rm -rf "$tmp"' EXIT

cd "$repo"
nix flake new "$consumer" --template "path:$repo#default"
cp "$repo/tests/consumer-generation/myHost.nix" "$consumer/modules/hosts/myHost/configuration.nix"
(cd "$consumer" && nix flake lock --override-input dotnix "path:$repo")

eval_direnv() (
  cd "$consumer"
  nix eval --json --override-input dotnix "path:$repo" \
    .#nixosConfigurations.myHost.config.home-manager.users.myuser.programs.direnv-instant.enable
)

assert_direnv_activated() {
  local phase="$1"
  local enabled
  enabled="$(eval_direnv)"
  if [[ $enabled != true ]]; then
    printf 'Direnv was not enabled %s: %s\n' "$phase" "$enabled" >&2
    exit 1
  fi
}

assert_no_consumer_direnv_input() {
  local present
  present="$(nix eval --impure --json --expr "let lock = builtins.fromJSON (builtins.readFile $consumer/flake.lock); in builtins.hasAttr ''direnv-instant'' lock.nodes.root.inputs")"
  if [[ $present != false ]]; then
    printf 'Consumer root unexpectedly declares direnv-instant: %s\n' "$present" >&2
    exit 1
  fi
}

assert_direnv_activated "before generation"
assert_no_consumer_direnv_input

(cd "$consumer" && nix run --override-input dotnix "path:$repo" .#write-flake)
assert_direnv_activated "after first generation"
assert_no_consumer_direnv_input
cp "$consumer/flake.nix" "$tmp/flake.after-first-generation"
cp "$consumer/flake.lock" "$tmp/lock.after-first-generation"

(cd "$consumer" && nix run --override-input dotnix "path:$repo" .#write-flake)
assert_direnv_activated "after repeated generation"
assert_no_consumer_direnv_input
cmp "$tmp/flake.after-first-generation" "$consumer/flake.nix"
cmp "$tmp/lock.after-first-generation" "$consumer/flake.lock"
printf 'Consumer generation lifecycle passed\n'
