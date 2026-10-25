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
  dotnix.dms = { inputs, ... }: {
    nixos =
      { host
      , config
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

          # U2F needs vault material like yubikey-pam: the u2f authfile secret
          # only exists once the vault is ready.
          lockscreen.securityKey =
            lib.mkIf
              (lib.pathExists "${inputs.self}/modules/hosts/${host.name}/secrets/ssh_host_ed25519_key.pub")
              {
                enable = true;
                moduleArgs = [
                  "cue"
                  "authfile=${config.age.secrets.u2f.path}"
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
