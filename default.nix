# Public flake-parts modules. Import this source-only input, not its flake.
{
  # Repository shell, formatter, and checks, without vault tooling.
  devtools = ./modules/devtools/repo.nix;

  # Extends devtools with the vault shell packages and generate/rekey apps.
  vault-tools = ./modules/devtools/vault.nix;

  # NixOS server features and system accounts, without Home Manager.
  system = ./modules/system;
}
