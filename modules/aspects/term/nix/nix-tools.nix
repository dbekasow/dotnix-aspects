{
  flake.modules.homeManager.nix-tools = { pkgs, ... }: {
    programs.nix-init.enable = true;

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
