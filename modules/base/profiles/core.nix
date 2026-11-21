{ dotnix, ... }:
let
  homeBaseline = with dotnix.home; [ ssh xdg ];
in
{
  dotnix.host.core.includes = with dotnix.host; [
    certificates
    fish
    git
    home-manager
    locale
    nh
    nix
    nix-ld
    security
    ssh
    system-packages
  ];

  dotnix.home.core.includes = homeBaseline;
  # Route the vault-free baseline even when a legacy import extends home.core.
  dotnix.host.home-manager.provides.to-users.includes = homeBaseline;
}
