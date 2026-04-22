{
  flake.modules.homeManager.jq = { pkgs, ... }: {
    programs.jq.enable = true;
    programs.jq.package = pkgs.gojq;

    home.packages = [ pkgs.yq-go ];
    home.shellAliases.jq = "gojq";
  };
}

