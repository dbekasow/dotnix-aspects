# Public flake-parts modules. Import this source-only input, not its flake.
{
  # Repository shell, formatter, checks, and vault commands.
  devtools = ./modules/devtools;
  # NixOS server features and system accounts, without Home Manager.
  system = ./modules/system;
  # Optional server services; import only for consumers that select them.
  server = ./modules/server;
  # Integrated Home Manager and non-graphical host, home, and account features.
  home = ./modules/base/home.nix;
  # Graphical features and their inputs; select them separately on each target.
  desktop = ./modules/desktop;
  # Headless hardware and PAM support; no Home Manager or Desktop required.
  yubikey = ./modules/base/yubikey.nix;
  # Runtime Age/Rekey features and generated account passwords.
  managedSecrets = ./modules/base/managed-secrets.nix;
}
