# Tier selection instead of host classes: workstations import `system`
# (workstation hardware), headless machines import `server` — a bootable
# socket without NetworkManager, avahi, audio or power management.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos; in {
    nixos.server.imports = with nixos; [
      boot
      boot-systemd
      journald
      performance
    ];
  };
}
