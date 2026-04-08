{
  flake.modules.nixos.users = { config, lib, pkgs, ... }: {
    users.defaultUserShell = pkgs.fish;
    users.mutableUsers = false;

    users.users = lib.genAttrs config.dotnix.host.members (name: {
      hashedPasswordFile = config.age.secrets."hashed-password-${name}".path;
    });

    age.secrets = lib.mergeAttrsList (map
      (name: {
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
      config.dotnix.host.members);

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;
  };
}
