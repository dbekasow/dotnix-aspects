# Public flake-parts modules. Import this source-only input, not its flake.
{
  # Repository shell, formatter, and checks, without vault tooling.
  devtools = ./modules/devtools/repo.nix;

  # Extends devtools with the vault shell packages and generate/rekey apps.
  vault-tools = ./modules/devtools/vault.nix;

  # NixOS server features and system accounts, without Home Manager.
  system = ./modules/system;
  # Integrated Home Manager and non-graphical host, home, and account features.
  home = ./modules/base/home.nix;
  # Headless hardware and PAM support; no Home Manager or Desktop required.
  yubikey = ./modules/base/yubikey.nix;
  # Runtime Age/Rekey features and generated account passwords.
  managedSecrets = ./modules/base/managed-secrets.nix;
}
