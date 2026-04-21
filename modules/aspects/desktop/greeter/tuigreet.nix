{
  flake.modules.nixos.tui-greeter = { lib, pkgs, ... }: {
    services.greetd = {
      enable = true;

      settings.default_session = {
        command = lib.concatStringsSep " " [
          (lib.getExe pkgs.tuigreet)
          "--remember"
          "--remember-session"
          "--time"
          "--asterisks"
        ];
        user = "greeter";
      };
    };
  };
}
