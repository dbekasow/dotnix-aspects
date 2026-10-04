{
  dotnix.jq.homeManager = { pkgs, ... }: {
    programs.jq.enable = true;
    programs.jq.package = pkgs.gojq;

    home.packages = [ pkgs.yq-go ];
    home.shellAliases.jq = "gojq";
  };
}

