{
  flake.modules.nixos.thunar = { pkgs, ... }: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-media-tags-plugin
        thunar-archive-plugin
        thunar-vcs-plugin
        thunar-volman
      ];
    };
    services.tumbler.enable = true;
  };
}
