{ inputs, ... }:
{
  dotnix.home.ai-tools.homeManager = { pkgs, ... }:
    let
      packages = pkgs.llm-agents or inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = with packages; [ skills tokscale ];
    };
}
