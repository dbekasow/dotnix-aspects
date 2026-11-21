#!/usr/bin/env bash
# Usage: bash tests/consumer-generation.sh EXISTING_EMPTY_DIRECTORY | --system-only
set -euo pipefail

usage() {
  printf 'Usage: %s EXISTING_EMPTY_DIRECTORY | --system-only\n' "${0##*/}" >&2
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

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

prepare_consumer() {
  local consumer="$1" fixture="$2"
  mkdir -p "$consumer/modules"
  cp "$repo/tests/consumer-generation/flake.nix" "$consumer/flake.nix"
  cp "$repo/tests/consumer-generation/$fixture" "$consumer/modules/$fixture"
  # The disposable source-only input is a snapshot of the library under test.
  cp -R --no-preserve=mode "$(cd "$repo" && nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).outPath')" "$consumer/library"
}

check_system() (
  prepare_consumer "$tmp/system" vps.nix
  cd "$tmp/system"
  # Use a path flake so the disposable files need not be tracked by Git.
  nix run path:.#write-flake
  nix flake lock path:.

  nix eval --json path:.#nixosConfigurations.vps --apply '
    { config, options, ... }:
    let user = config.users.users.operator; in
    assert config.services.openssh.enable;
    assert !config.services.openssh.settings.PasswordAuthentication;
    assert user.isNormalUser;
    assert user.openssh.authorizedKeys.keys == [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdamAGCsQq31Uv+08lkBzoO4XLz2qYjJa8CGmj3B1Ea vps-fixture" ];
    assert !(options ? age || options ? home-manager);
    assert user.hashedPasswordFile == null && user.hashedPassword == null && user.password == null;
    builtins.seq config.system.build.toplevel.drvPath true
  '

  nix eval --json path:.#denful.dotnix --apply '
    dotnix:
    assert !(dotnix.host ? home-manager);
    assert (dotnix.home or {}) == {};
    true
  '

  # The freshly generated lock includes all reachable inputs, including transitive ones.
  # shellcheck disable=SC2016
  nix eval --impure --json --expr '
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      root = lock.nodes.${lock.root}.inputs;
      library = lock.nodes.${root.dotnix};
    in
    assert !library.flake && (library.inputs or {}) == {};
    assert !(root ? home-manager);
    assert !(builtins.any (node: (node.locked.repo or "") == "home-manager") (builtins.attrValues lock.nodes));
    true
  '
  printf 'System-only Consumer generation passed\n'
)

if [[ $1 == --system-only ]]; then
  tmp="$(mktemp -d "$repo/.dotnix-consumer-generation.XXXXXX")"
  trap 'rm -rf -- "$tmp"' EXIT
  check_system
  exit
fi

case "/$1/" in
*"/../"*) refuse "destination path must not contain '..' components" ;;
esac
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

check_system
prepare_consumer "$consumer" myHost.nix
cd "$consumer"
nix run .#write-flake
nix flake lock

# shellcheck disable=SC2016
nix eval --json .#nixosConfigurations.myHost --apply '
  {config, options, pkgs, ...}:
  let
    home = config.home-manager.users.myuser;
    accountsConf = home.home.file."${home.xdg.configHome}/aerc/accounts.conf".text;
    hasSystemPackage = name: builtins.any (p: (p.pname or p.name) == name) config.environment.systemPackages;
  in
  assert !(hasSystemPackage "pavucontrol" || hasSystemPackage "yubioath-flutter");
  assert home.programs.direnv-instant.enable;
  assert home.programs.tmux.enable;
  assert home.programs.helix.enable;
  assert builtins.any (p: (p.pname or p.name) == "hunk") home.home.packages;
  assert !(builtins.any (p: (p.pname or p.name) == "wl-clipboard") home.home.packages);
  assert home.xdg.userDirs.enable;
  assert home.services.gpg-agent.pinentry.package.pname == "pinentry-curses";
  assert home.programs.rbw.settings.pinentry == (toString pkgs.pinentry-curses + "/bin/pinentry");
  assert home.programs.aerc.enable;
  assert pkgs.lib.hasInfix "from = Consumer Fixture <fixture@example.com>" accountsConf;
  assert pkgs.lib.hasInfix "source-cred-cmd = fixture-mail-password" accountsConf;
  assert home.programs.git.enable;
  assert home.programs.git.settings.user == { name = "Fixture Author"; email = "author@example.com"; };
  assert !(options ? age || home ? age);
  builtins.seq home.home.activationPackage.drvPath true
'

nix eval --json .#denful.dotnix --apply '
  dotnix:
  assert dotnix.host ? home-manager && dotnix.home ? aerc;
  assert !(dotnix.host ? graphical || dotnix.host ? niri || dotnix.host ? dms || dotnix.host ? yubioath-flutter);
  assert !(dotnix.home ? graphical || dotnix.home ? clipboard || dotnix.home ? gpg-agent-gui || dotnix.home ? rbw-gui);
  assert !(dotnix.host ? yubikey || dotnix.host ? yubikey-pam);
  true
'

# Nix writes the reachable nodes of the lock graph, including transitive inputs.
# shellcheck disable=SC2016
nix eval --impure --json --expr '
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    root = lock.nodes.${lock.root}.inputs;
    library = lock.nodes.${root.dotnix};
    excludedRepos = [ "niri-flake" "DankMaterialShell" "dank-greeter" "dms-plugin-registry" "noctalia" "noctalia-greeter" "NUR" "stylix" "agenix" "agenix-rekey" ];
  in
  assert !library.flake && (library.inputs or {}) == {};
  assert lock.nodes.${root.home-manager}.locked.repo == "home-manager";
  assert !(builtins.any (node: builtins.elem (node.locked.repo or "") excludedRepos) (builtins.attrValues lock.nodes));
  assert !(root ? devshell || root ? git-hooks || root ? treefmt);
  true
'
printf 'Work Consumer generation passed\n'

# Repository tools work without vault dependencies; adding vault-tools restores the opt-in flows.
(
  cp -R "$consumer" "$tmp/devtools"
  cd "$tmp/devtools"
  cat >modules/devtools.nix <<'EOF'
{ inputs, ... }: {
  imports = [ (import inputs.dotnix).devtools ];
}
EOF
  nix run .#write-flake
  nix flake lock

  # shellcheck disable=SC2016
  nix eval --impure --json --expr '
    let
      outputs = builtins.getFlake (toString ./.);
      system = "x86_64-linux";
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      packages = map (p: p.pname or p.name) outputs.devShells.${system}.default.config.devshell.packages;
      apps = (outputs.apps or {}).${system} or {};
    in
    assert !(builtins.any (node: (node.locked.repo or "") == "agenix-rekey") (builtins.attrValues lock.nodes));
    assert !(builtins.any (name: builtins.elem name packages) [ "rage" "agenix" "age-plugin-yubikey" ]);
    assert !(apps ? generate || apps ? rekey);
    {
      shell = outputs.devShells.${system}.default.drvPath;
      formatter = outputs.formatter.${system}.drvPath;
      pre-commit = outputs.checks.${system}.pre-commit.drvPath;
      treefmt = outputs.checks.${system}.treefmt.drvPath;
    }
  '

  sed -i 's/\.devtools ]/.vault-tools ]/' modules/devtools.nix
  nix run .#write-flake
  nix flake lock

  # shellcheck disable=SC2016
  nix eval --impure --json --expr '
    let
      outputs = builtins.getFlake (toString ./.);
      system = "x86_64-linux";
      packages = map (p: p.pname or p.name) outputs.devShells.${system}.default.config.devshell.packages;
    in
    assert builtins.all (name: builtins.elem name packages) [ "rage" "agenix" "age-plugin-yubikey" ];
    {
      inherit (outputs.apps.${system}.generate) program;
      rekey = outputs.apps.${system}.rekey.program;
    }
  '
  printf 'Repository tools and explicit vault tooling passed\n'
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
