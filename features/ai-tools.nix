{ inputs, ... }:
{
  dotnix.ai-tools.homeManager = { pkgs, ... }:
    let
      packages = pkgs.llm-agents or inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = with packages; [
        beads # distributed issue tracker
        beads-viewer # tui for beads issue tracker
        skills # skill tool installer
        tokscale # token analytics
      ];
    };
}
