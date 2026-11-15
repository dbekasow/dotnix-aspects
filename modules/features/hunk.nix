{ inputs, ... }:
let
  hunkFor = pkgs:
    (pkgs.llm-agents or inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}).hunk;
in
{
  dotnix.home.hunk = {
    homeManager = { lib, pkgs, ... }:
      let hunk = hunkFor pkgs; in
      {
        home.packages = [ hunk ];
        programs.fish.shellAbbrs.cr = lib.getExe hunk;
      };

    popup-launcher = { lib, pkgs, ... }: [
      {
        name = "hunk";
        command = lib.getExe (hunkFor pkgs);
        width = "90%";
        height = "85%";
        key = "r";
        enable = _: true;
      }
    ];
  };
}
