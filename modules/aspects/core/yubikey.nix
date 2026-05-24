{

  flake.modules.nixos.yubikey = { pkgs, ... }: {
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
  };

  flake.modules.nixos.yubikey-pam = { config, pkgs, ... }: {
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
      services.greetd.u2fAuth = true;
      services.login.u2fAuth = true;
      services.sudo.u2fAuth = true;
    };

    programs.yubikey-manager.enable = true;
    environment.systemPackages = with pkgs; [ yubioath-flutter yubikey-manager ];
  };
}
