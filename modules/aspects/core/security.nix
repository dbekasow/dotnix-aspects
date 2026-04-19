{
  flake.modules.nixos.security = { lib, ... }: {
    security.sudo.enable = lib.mkForce false;
    security.sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false;
    };

    security.rtkit.enable = true;
    security.polkit.enable = true;

    systemd.coredump.enable = false;
  };
}
