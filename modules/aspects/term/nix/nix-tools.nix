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

  # Persist the per-user Nix cache
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/nix" ];
  };
}
