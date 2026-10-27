{
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
    environment.systemPackages = with pkgs; [ yubioath-flutter yubikey-manager ];
  };
}
