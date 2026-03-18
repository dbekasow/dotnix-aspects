{
  flake.modules.nixos.core = { config, lib, pkgs, ... }: {
    users.defaultUserShell = pkgs.fish;
    users.mutableUsers = false;

    users.users = builtins.mapAttrs
      (name: cfg: {
        inherit (cfg) isNormalUser extraGroups;
        hashedPasswordFile = config.age.secrets."hashed-password-${name}".path;
      })
      config.dotnix.host.members;

    age.secrets = lib.concatMapAttrs
      (name: _value: {
        "password-${name}" = {
          generator.script = "alnum";
          intermediary = true;
        };
        "hashed-password-${name}" = {
          generator = {
            dependencies = [ config.age.secrets."password-${name}" ];
            script = { pkgs, decrypt, deps, ... }: ''
              ${decrypt} ${lib.escapeShellArg (lib.head deps).file} | \
              ${pkgs.openssl}/bin/openssl passwd -6 stdin
            '';
          };
        };
      })
      config.dotnix.host.members;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;
  };
}
