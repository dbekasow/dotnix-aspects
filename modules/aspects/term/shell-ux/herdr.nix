{ inputs, ... }: {
  flake.modules.homeManager.herdr = { lib, pkgs, ... }:
    let
      toml = pkgs.formats.toml { };
    in
    {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr ];
      xdg.configFile."herdr/config.toml".source = toml.generate "herdr.toml" {
        terminal.default_shell = lib.getExe pkgs.fish;
      };
    };
}
