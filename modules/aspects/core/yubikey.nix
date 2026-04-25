{
  flake.modules.nixos.yubikey = { config, pkgs, ... }: {
    age.secrets.u2f.generator.script = { ... }: ''
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

    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

    programs.yubikey-manager.enable = true;
    environment.systemPackages = with pkgs; [ yubioath-flutter yubikey-manager ];
  };

  flake.modules.homeManager.yubikey = { pkgs, ... }: {
    programs.gpg.scdaemonSettings.disable-ccid = true;
    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
  };
}
