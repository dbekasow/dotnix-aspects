#!/usr/bin/env bash
# Usage: bash tests/consumer-generation.sh /path/to/existing-empty-directory
set -euo pipefail

usage() {
  printf 'Usage: %s EXISTING_EMPTY_DIRECTORY\n' "${0##*/}" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi
if [[ -z $1 ]]; then
  usage
  exit 2
fi

normalize_path() {
  local path="$1"
  local component
  local -a components=() stack=()
  [[ $path == /* ]] || path="$PWD/$path"
  IFS=/ read -r -a components <<<"$path"
  for component in "${components[@]}"; do
    case "$component" in
    "" | .) ;;
    ..)
      if ((${#stack[@]} > 0)); then
        unset "stack[$((${#stack[@]} - 1))]"
      fi
      ;;
    *) stack+=("$component") ;;
    esac
  done

  local normalized="/"
  for component in "${stack[@]}"; do
    if [[ $normalized == / ]]; then
      normalized+="$component"
    else
      normalized+="/$component"
    fi
  done
  printf '%s\n' "$normalized"
}

within_or_equal() {
  [[ $1 == "$2" || $1 == "$2/"* ]]
}

validate_destination_location() {
  if [[ $destination == "$repo" ]] || within_or_equal "$repo" "$destination"; then
    refuse "destination overlaps protected path '$repo'"
  fi
  for protected in "$home" "$original" "$private"; do
    if within_or_equal "$destination" "$protected" || within_or_equal "$protected" "$destination"; then
      refuse "destination overlaps protected path '$protected'"
    fi
  done
  if within_or_equal "$destination" "$repo" && ! git -C "$repo" check-ignore -q -- "$destination"; then
    refuse "destination inside repository must be git-ignored: $destination"
  fi
}

refuse() {
  printf 'Refusing consumer generation destination: %s\n' "$1" >&2
  exit 1
}

case "/$1/" in
*"/../"*) refuse "destination path must not contain '..' components" ;;
esac

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
destination="$(normalize_path "$1")"
home="$(normalize_path "${HOME:?HOME must be set}")"
original="/home/denis/projects/dotnix-aspects"
private="/home/denis/projects/dotnix"

[[ $destination != / ]] || refuse 'filesystem root is not a suitable destination'
validate_destination_location

current="/"
IFS=/ read -r -a components <<<"$destination"
for component in "${components[@]}"; do
  [[ -n $component ]] || continue
  if [[ $current == / ]]; then
    current+="$component"
  else
    current+="/$component"
  fi
  [[ ! -L $current ]] || refuse "destination path contains symlink '$current'"
done
[[ -d $destination ]] || refuse "destination must be an existing directory: $destination"
destination="$(cd "$destination" && pwd -P)"
validate_destination_location

shopt -s dotglob nullglob
contents=("$destination"/*)
shopt -u dotglob nullglob
((${#contents[@]} == 0)) || refuse "destination must be empty: $destination"

tmp="$(mktemp -d "$destination/.dotnix-consumer-generation.XXXXXX")"
consumer="$tmp/consumer"
trap 'rm -rf -- "$tmp"' EXIT

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
