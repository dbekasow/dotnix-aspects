{ dotnix, ... }:
{
  imports = [
    ./home.nix
    ./managed-secrets.nix
    ./yubikey.nix
  ];

  # Preserve the previous core selections for legacy Base imports only.
  dotnix.host.core.includes = [ dotnix.host.age ];
  dotnix.home.core.includes = with dotnix.home; [ age age-rekey ];
}
