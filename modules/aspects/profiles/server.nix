# Tier selection instead of host classes: workstations import `system`
# (workstation hardware), headless machines import `server` — the base
# boot socket without NetworkManager, avahi, audio or power management.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos; in {
    nixos.server.imports = with nixos; [ base ];
  };
}
