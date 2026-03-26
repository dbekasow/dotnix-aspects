{
  flake.modules.homeManager.terminal = { pkgs, ... }: {

    programs.nix-init.enable = true;
    programs.nix-search-tv.enable = true;
    programs.nix-search-tv.enableTelevisionIntegration = true;

    home.packages = with pkgs; [
      nh
      nvd
      nurl
      nix-tree
      nix-inspect
      nix-search-cli
      nix-output-monitor
    ];
  };
}
