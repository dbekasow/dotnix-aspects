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
for protected in "$repo" "$home" "$original" "$private"; do
  if within_or_equal "$destination" "$protected" || within_or_equal "$protected" "$destination"; then
    refuse "destination overlaps protected path '$protected'"
  fi
done

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
for protected in "$repo" "$home" "$original" "$private"; do
  if within_or_equal "$destination" "$protected" || within_or_equal "$protected" "$destination"; then
    refuse "destination overlaps protected path '$protected'"
  fi
done

shopt -s dotglob nullglob
contents=("$destination"/*)
shopt -u dotglob nullglob
((${#contents[@]} == 0)) || refuse "destination must be empty: $destination"

tmp="$(mktemp -d "$destination/.dotnix-consumer-generation.XXXXXX")"
consumer="$tmp/consumer"
trap 'rm -rf -- "$tmp"' EXIT

cd "$repo"
mkdir -p "$consumer/modules"
cp tests/consumer-generation/flake.nix "$consumer/flake.nix"
cp tests/consumer-generation/myHost.nix "$consumer/modules/myHost.nix"
# The disposable source-only input is a snapshot of the library under test.
cp -R --no-preserve=mode "$(nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).outPath')" "$consumer/library"

cd "$consumer"
nix run .#write-flake
nix flake lock

nix eval --json .#nixosConfigurations.myHost --apply '
  {config, pkgs, ...}:
  let home = config.home-manager.users.myuser; in
  assert home.programs.direnv-instant.enable;
  assert home.programs.tmux.enable;
  assert home.programs.helix.enable;
  assert builtins.any (p: (p.pname or p.name) == "hunk") home.home.packages;
  assert !(builtins.any (p: (p.pname or p.name) == "wl-clipboard") home.home.packages);
  assert home.xdg.userDirs.enable;
  assert home.services.gpg-agent.pinentry.package.pname == "pinentry-curses";
  assert home.programs.rbw.settings.pinentry == (toString pkgs.pinentry-curses + "/bin/pinentry");
  assert config.age.rekey.storageMode == "local" && home.age.rekey.storageMode == "local";
  true
'

nix eval --json .#denful.dotnix --apply '
  dotnix:
  assert !(dotnix.host ? graphical || dotnix.host ? niri || dotnix.host ? dms);
  assert !(dotnix.home ? graphical || dotnix.home ? clipboard || dotnix.home ? gpg-agent-gui || dotnix.home ? rbw-gui);
  true
'

# Nix writes the reachable nodes of the lock graph, including transitive inputs.
# shellcheck disable=SC2016
nix eval --impure --json --expr '
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    root = lock.nodes.${lock.root}.inputs;
    library = lock.nodes.${root.dotnix};
    desktopRepos = [ "niri-flake" "DankMaterialShell" "dank-greeter" "dms-plugin-registry" "noctalia" "noctalia-greeter" "NUR" "stylix" ];
  in
  assert !library.flake && (library.inputs or {}) == {};
  assert !(builtins.any (node: builtins.elem (node.locked.repo or "") desktopRepos) (builtins.attrValues lock.nodes));
  assert !(root ? devshell || root ? git-hooks || root ? treefmt);
  true
'

# Opt into DevTools from the existing Base flake and lock without changing either.
(
  cp -R "$consumer" "$tmp/devtools"
  cd "$tmp/devtools"
  cat >modules/devtools.nix <<'EOF'
{ inputs, ... }: {
  imports = [ (inputs.dotnix + "/modules/devtools.nix") ];
}
EOF
  nix run .#write-flake
  nix flake lock

  # shellcheck disable=SC2016
  nix eval --impure --json --expr '
    let
      readLock = path: let lock = builtins.fromJSON (builtins.readFile path); in {
        inherit (lock) nodes;
        root = lock.nodes.${lock.root}.inputs;
      };
      base = readLock ../consumer/flake.lock;
      optIn = readLock ./flake.lock;
      rekey = optIn.nodes.${optIn.root.agenix-rekey}.inputs;
      outputs = builtins.getFlake (toString ./.);
      system = "x86_64-linux";
    in
    assert builtins.attrNames optIn.root == builtins.attrNames (base.root // { devshell = null; git-hooks = null; treefmt = null; });
    assert rekey.devshell == [ "devshell" ];
    assert rekey.pre-commit-hooks == [ "git-hooks" ];
    assert rekey.treefmt-nix == [ "treefmt" ];
    assert !(outputs.denful.dotnix.host ? niri || outputs.denful.dotnix.home ? graphical);
    {
      shell = outputs.devShells.${system}.default.drvPath;
      formatter = outputs.formatter.${system}.drvPath;
      pre-commit = outputs.checks.${system}.pre-commit.drvPath;
      treefmt = outputs.checks.${system}.treefmt.drvPath;
      generate = outputs.apps.${system}.generate.program;
      rekey = outputs.apps.${system}.rekey.program;
    }
  '
)

cp flake.nix "$tmp/flake.after-first-generation"
cp flake.lock "$tmp/lock.after-first-generation"

check_desktop() {
  cp modules/myHost.nix "$tmp/myHost.base.nix"
  sed 's/withDesktop = false;/withDesktop = true;/' "$tmp/myHost.base.nix" >modules/myHost.nix
  nix run .#write-flake
  nix flake lock

  nix eval --json .#denful.dotnix --apply '
    dotnix:
    assert dotnix.host ? niri && dotnix.home ? graphical;
    true
  '

  # shellcheck disable=SC2016
  nix eval --json .#nixosConfigurations --apply '
    {graphicalHost, myHost, ...}:
    let
      graphicalHome = graphicalHost.config.home-manager.users.myuser;
      headlessHome = myHost.config.home-manager.users.myuser;
      hasClipboard = home: builtins.any (p: (p.pname or p.name) == "wl-clipboard") home.home.packages;
      pinentry = pkgs: name: toString pkgs.${name} + "/bin/pinentry";
    in
    assert graphicalHost.config.programs.niri.enable;
    assert !(myHost.config.programs.niri.enable or false);
    assert hasClipboard graphicalHome && !(hasClipboard headlessHome);
    assert graphicalHome.services.gpg-agent.pinentry.package.pname == "pinentry-gnome3";
    assert headlessHome.services.gpg-agent.pinentry.package.pname == "pinentry-curses";
    assert graphicalHome.programs.rbw.settings.pinentry == pinentry graphicalHost.pkgs "pinentry-gnome3";
    assert headlessHome.programs.rbw.settings.pinentry == pinentry myHost.pkgs "pinentry-curses";
    true
  '

  # shellcheck disable=SC2016
  nix eval --impure --json --expr '
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      root = lock.nodes.${lock.root}.inputs;
    in
    assert lock.nodes.${root.niri}.locked.repo == "niri-flake";
    assert !(root ? devshell || root ? git-hooks || root ? treefmt);
    true
  '

  mv "$tmp/myHost.base.nix" modules/myHost.nix
  nix run .#write-flake
  nix flake lock
  nix eval --json .#denful.dotnix --apply '
    dotnix:
    assert !(dotnix.host ? niri || dotnix.home ? graphical);
    true
  '
  printf 'Desktop Consumer opt-in and removal passed\n'
}
check_desktop

nix run .#write-flake
nix flake lock
cmp "$tmp/flake.after-first-generation" flake.nix
cmp "$tmp/lock.after-first-generation" flake.lock
printf 'Base Consumer generation lifecycle passed\n'
