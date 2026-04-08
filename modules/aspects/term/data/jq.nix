{
  flake.modules.homeManager.jq = { pkgs, ... }: {
    programs.jq.enable = true;
    programs.jq.package = pkgs.gojq;

    programs.jqp.enable = true;
  };
}

