{ dotnix, ... }:
{
  dotnix.host.yubikey-pam-age = {
    includes = [ dotnix.host.yubikey-pam ];
    nixos = { config, lib, ... }: {
      age.secrets.u2f.generator.script = _: ''
        printf '# nix shell nixpkgs#pam_u2f -c pamu2fcfg -u $(whoami) -o pam://$(hostname) -i pam://$(hostname)'
      '';
      security.pam.u2f.settings.authfile = lib.mkDefault config.age.secrets.u2f.path;
    };
  };

  dotnix.host.yubikey-pam.nixos = { lib, pkgs, ... }: {
    # Consumers supply an authfile through the native
    # `security.pam.u2f.settings.authfile` option, or use its NixOS default.
    # This feature does not require agenix-rekey or desktop support.
    security.pam.u2f = {
      enable = true;

      settings = {
        interactive = lib.mkDefault true;
        cue = lib.mkDefault true;
        nouserok = lib.mkDefault true;
      };
    };

    # pam.u2f.enable installs pam_u2f into PAM services unless opted out.
    # That host-wide authentication floor is intentional.
    programs.yubikey-manager.enable = true;
    environment.systemPackages = [ pkgs.yubikey-manager ];
  };
}
