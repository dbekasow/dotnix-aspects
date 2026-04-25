{
  flake.modules.nixos.bluetooth = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General.Experimental = true;
        General.FastConnectable = true;
      };
    };

    environment.systemPackages = [ pkgs.bluetui ];
  };
}
