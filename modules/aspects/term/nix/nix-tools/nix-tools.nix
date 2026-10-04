{
  flake.modules.homeManager.nix-tools = { pkgs, ... }: {
    programs.nix-init.enable = true;

    home.packages = with pkgs; [
      nh
      nvd
      nurl
      nix-graph
      nix-inspect
      nix-search-cli
      nix-output-monitor
    ];
  };

  # Impermanence contribution for nix-tools.
  # Persist the per-user Nix cache
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/nix" ];
  };
}
