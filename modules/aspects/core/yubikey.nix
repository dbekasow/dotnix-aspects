{
  flake.modules.nixos.yubikey = { lib, pkgs, ... }: {
    security.pam.u2f = {
      enable = true;

      settings = {
        origin = "pam://yubi";
        authfile = pkgs.writeText "u2f-mappings" (lib.concatStrings [
          "dns"
          ":<KeyHandle1>,<UserKey1>,<CaseType1>,<Options1>"
          ":<KeyHandle2>,<UserKey2>,<CaseType2>,<Options2>"
        ]);
        interactive = true;
        cue = true;
      };
    };

    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };

    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

    programs.yubikey-manager.enable = true;
  };
}
