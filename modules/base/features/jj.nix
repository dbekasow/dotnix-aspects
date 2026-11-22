{
  dotnix.home.jj.homeManager = { config, lib, ... }:
    let
      gitUser = config.programs.git.settings.user or { };
    in
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = lib.optionalAttrs (gitUser ? name && gitUser ? email) {
            name = lib.mkDefault gitUser.name;
            email = lib.mkDefault gitUser.email;
          };
          ui = lib.mkIf (config.programs.helix.enable && config.programs.helix.package != null) {
            editor = lib.mkDefault (lib.getExe config.programs.helix.package);
          };
        };
      };
    };
}
