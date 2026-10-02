# Shared boot socket for every bootable tier: `system` (workstation) and
# `server` (headless) inherit it instead of re-listing boot machinery.
# Headless-agnostic on purpose — `performance` is laptop-tuned but
# functionally generic; re-check these base assumptions whenever a future
# headless tier needs its own tuning.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos; in {
    nixos.base.imports = with nixos; [
      boot
      boot-systemd
      journald
      performance
    ];
  };
}
