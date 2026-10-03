{
  flake.modules.nixos.security = { lib, ... }: {
    # No `security.sudo.enable = false` here: the sudo-rs module already
    # disables legacy sudo by default, and forcing it would break hosts
    # that deliberately keep legacy sudo.
    security.sudo-rs = {
      enable = true;
      execWheelOnly = true;
      # Passwordless wheel access requires an explicit host override backed
      # by a real hardware authentication gate.
      wheelNeedsPassword = lib.mkDefault true;
    };

    security.rtkit.enable = true;
    security.polkit.enable = true;

    systemd.coredump.enable = false;
  };
}
