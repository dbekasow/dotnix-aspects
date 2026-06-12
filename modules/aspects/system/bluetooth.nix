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

  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];
  };
}
