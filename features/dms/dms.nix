{ inputs, ... }:
let
  # Library dependency inputs (the DMS modules) stay closed over the library
  # flake; the vault path resolves from the aspect `inputs` argument (consumer
  # flake) exposed by den.batteries.flake-scope.
  libraryInputs = inputs;
in
{
  flake-file.inputs.dms = {
    url = "github:AvengeMedia/DankMaterialShell";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  dotnix.dms = _: {
    nixos =
      { config
      , lib
      , pkgs
      , ...
      }:
      {
        imports = [
          {
            key = "${libraryInputs.dms}/nixosModules/dank-material-shell";
            imports = [ libraryInputs.dms.nixosModules.dank-material-shell ];
          }
        ];

        programs.dank-material-shell = {
          enable = true;

          systemd.enable = true;
          systemd.restartIfChanged = true;

          # DMS follows the native host U2F configuration when selected; it
          # does not infer an authfile path or require secret tooling.
          lockscreen.securityKey = lib.mkIf
            (config.security.pam.u2f.enable && config.security.pam.u2f.settings.authfile != null)
            {
              enable = true;
              moduleArgs = [
                "cue"
                "authfile=${config.security.pam.u2f.settings.authfile}"
              ];
            };
        };

        programs.dsearch.enable = true;

        # The fprintd package alone starts nothing — the service wires PAM
        # auth. mkDefault so hosts without a reader can set it to false.
        services.fprintd.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          cups-pk-helper # printer management
        ];
      };

    homeManager = { ... }: {
      imports = with libraryInputs; [
        dms.homeModules.dank-material-shell
        dms.homeModules.niri
      ];

      programs.dank-material-shell = {
        enable = true;

        enableAudioWavelength = true;
        enableCalendarEvents = true;
        enableClipboardPaste = true;
        enableDynamicTheming = true;
        enableSystemMonitoring = true;

        clipboardSettings.clearAtStartup = true;
        clipboardSettings.maxHistory = 25;

        session.isLightMode = false;
      };

      # No local config.kdl override: upstream generates identical output incl. border fix — verified against rev a609b5f, see docs/recherche-2026-10-02/oracle-desktop.md
    };

    # Impermanence contribution for dms.
    homePersistence = {
      home.persistence."/persist".directories = [ ".config/niri/dms" ];
    };
  };
}
