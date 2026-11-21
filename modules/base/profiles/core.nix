{ dotnix, ... }:
let
  homeBaseline = with dotnix.home; [ ssh xdg ];
in
{
  dotnix.host.core.includes = with dotnix.host; [
    certificates
    home-manager
    locale
    nix
    security
    ssh
    system-packages
  ];

  dotnix.home.core.includes = homeBaseline;
  # Route the vault-free baseline even when a legacy import extends home.core.
  dotnix.host.home-manager.provides.to-users.includes = homeBaseline;
}
