{
  flake.modules.nixos.security = {
    security.rtkit.enable = true;
    security.polkit.enable = true;

    security.sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false;
    };
  };
}
