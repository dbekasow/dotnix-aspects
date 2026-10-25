#!/usr/bin/env bash
# Run with `bash tests/password-recipe.sh` from the repository root.
# Evaluates the selected library password recipe, executes its real generator
# script with a stub decrypt command, and verifies its hash matches plaintext.
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
temp_dir="/tmp/den-password-recipe-$$"
if [[ -e $temp_dir ]]; then
  printf 'temporary path already exists: %s\n' "$temp_dir" >&2
  exit 1
fi
mkdir "$temp_dir"
trap 'rm -rf -- "$temp_dir"' EXIT
mkdir -p "$temp_dir/secrets" "$temp_dir/bin"
export PASSWORD_RECIPE_REPO="$repo_root"
printf 'synthetic public key marker\n' >"$temp_dir/secrets/ssh_host_ed25519_key.pub"
printf 'synthetic encrypted dependency marker\n' >"$temp_dir/dependency"

bash_bin=$(command -v bash)
cat >"$temp_dir/bin/decrypt" <<DECRYPT
#!$bash_bin
set -euo pipefail
printf '%s' 'synthetic-password-for-test'
DECRYPT
chmod +x "$temp_dir/bin/decrypt"

openssl_drv=$(nix eval --impure --no-write-lock-file --raw --expr '
  let
    source = builtins.getFlake (builtins.getEnv "PASSWORD_RECIPE_REPO");
    pkgs = import source.inputs.nixpkgs { system = "x86_64-linux"; };
  in pkgs.openssl.drvPath
')
openssl_out=$(nix build --no-link --no-write-lock-file --print-out-paths "${openssl_drv}^bin")
openssl_bin="$openssl_out/bin/openssl"
if [[ ! -x $openssl_bin ]]; then
  printf 'nixpkgs OpenSSL executable missing: %s\n' "$openssl_bin" >&2
  exit 1
fi
openssl_prefix=${openssl_bin%/bin/openssl}

nix_expr=$(
  cat <<'NIX'
let
  source = builtins.getFlake (builtins.getEnv "PASSWORD_RECIPE_REPO");
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  instantiate = args: nixpkgs.lib.nixosSystem (args // {
    pkgs = import nixpkgs { inherit system; };
  });
  fixture = {
    imports = [ source.flakeModules.default ];
    den.hosts.${system}.fixture = {
      users.fixture.classes = [ "user" ];
      inherit instantiate;
    };
    den.aspects.fixture = {
      includes = with dotnix; [ age age-rekey ];
      nixos = {
        boot.loader.grub.enable = true;
        boot.loader.grub.device = "nodev";
        fileSystems."/".device = "/dev/vda";
        fileSystems."/".fsType = "ext4";
        system.stateVersion = "25.11";
        nixpkgs.hostPlatform = system;
        age.rekey.secretsDir = lib.mkForce (builtins.getEnv "PASSWORD_RECIPE_SECRETS_DIR");
      };
      provides.fixture.includes = [ dotnix.account.passwords ];
    };
  };
  flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
  generator = flake.nixosConfigurations.fixture.config.age.secrets."password-fixture-hashed".generator;
in
  generator.script {
    pkgs.openssl = builtins.getEnv "PASSWORD_RECIPE_OPENSSL_PREFIX";
    decrypt = builtins.getEnv "PASSWORD_RECIPE_DECRYPT";
    deps = [ { file = builtins.getEnv "PASSWORD_RECIPE_DEPENDENCY"; } ];
  }
NIX
)

export PASSWORD_RECIPE_SECRETS_DIR="$temp_dir/secrets"
export PASSWORD_RECIPE_DECRYPT="$temp_dir/bin/decrypt"
export PASSWORD_RECIPE_DEPENDENCY="$temp_dir/dependency"
export PASSWORD_RECIPE_OPENSSL_PREFIX="$openssl_prefix"
generator_script=$(nix eval --impure --no-write-lock-file --raw --expr "$nix_expr")
actual_hash=$(bash -c "$generator_script" </dev/null)

synthetic_plaintext='synthetic-password-for-test'
expected_hash=''
if [[ $actual_hash == \$6\$* ]]; then
  salt=${actual_hash#\$6\$}
  salt=${salt%%\$*}
  if [[ -n $salt ]]; then
    expected_hash=$(printf '%s' "$synthetic_plaintext" | "$openssl_bin" passwd -6 -salt "$salt" -stdin)
  fi
fi
if [[ -z $expected_hash || $actual_hash != "$expected_hash" ]]; then
  expected_hash=$(printf '%s' "$synthetic_plaintext" | "$openssl_bin" passwd -6 -salt regression-salt -stdin)
  printf 'password recipe hash mismatch\nactual:   %s\nexpected: %s\n' "$actual_hash" "$expected_hash" >&2
  exit 1
fi

printf 'password recipe hash matches synthetic plaintext: %s\n' "$actual_hash"
