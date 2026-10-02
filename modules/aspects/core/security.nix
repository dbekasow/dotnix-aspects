{
  flake.modules.nixos.security = { lib, ... }: {
    # No `security.sudo.enable = false` here: the sudo-rs module already
    # disables legacy sudo by default, and forcing it would break hosts
    # that deliberately keep legacy sudo.
    security.sudo-rs = {
      enable = true;
      execWheelOnly = true;
      # Passwordless wheel is a convenience tradeoff for the workstation
      # context this library assumes — yubikey-pam gates login and
      # lockscreen, so anything past those owns the session anyway — not
      # a security floor. mkDefault so hosts without that gate (headless
      # servers) can require a password.
      wheelNeedsPassword = lib.mkDefault false;
    };

    security.rtkit.enable = true;
    security.polkit.enable = true;

    systemd.coredump.enable = false;
  };
}
