{
  # u2f login needs vault material — the whole aspect follows the gate.
  flake.modules.nixos.yubikey-pam = { config, lib, pkgs, ... }: lib.mkIf config.dotnix.vaultReady {
    age.secrets.u2f.generator.script = _: ''
      printf '# nix shell nixpkgs#pam_u2f -c pamu2fcfg -u $(whoami) -o pam://$(hostname) -i pam://$(hostname)'
    '';

    security.pam = {
      u2f = {
        enable = true;

        settings = {
          authfile = config.age.secrets.u2f.path;
          interactive = true;
          cue = true;
          nouserok = true;
        };
      };

      services.sudo.u2f.enable = true;
    };

    programs.yubikey-manager.enable = true;
    environment.systemPackages = with pkgs; [ yubioath-flutter yubikey-manager ];
  };
}
