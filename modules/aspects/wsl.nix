{ inputs, ... }: {
  flake.modules.nixos.wsl = { config, lib, ... }: with lib; {
    imports = [ inputs.wsl.nixosModules.default ];

    wsl = let inherit (config.dotnix) host; in {
      enable = mkDefault true;
      defaultUser = head (attrNames host.members);
    };
  };
}
