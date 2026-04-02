{
  perSystem = {
    devshells.default.commands = [
      # --- dev ---
      {
        category = "dev";
        name = "fmt";
        help = "Format the repo with treefmt";
        command = ''treefmt'';
      }
      {
        category = "dev";
        name = "check";
        help = "Run flake checks";
        command = ''nix flake check'';
      }
      # --- deploy ---
      {
        category = "deploy";
        name = "switch";
        help = "Rebuild and activate";
        command = ''nh os switch -- "''${@}"'';
      }
      {
        category = "deploy";
        name = "test";
        help = "Rebuild and activate without bootloader entry";
        command = ''nh os test -- "''${@}"'';
      }
      {
        category = "deploy";
        name = "build";
        help = "Build system without activating";
        command = ''nh os build -- "''${@}"'';
      }
      # --- maintenance ---
      {
        category = "maintenance";
        name = "update";
        help = "Update all flake inputs";
        command = ''nix flake update'';
      }
      {
        category = "maintenance";
        name = "gc";
        help = "Collect garbage";
        command = ''nh clean all --keep 3 --keep-since 7d'';
      }
    ];

    devshells.default.devshell.motd = ''
      {147}dotnix{reset} - type {italic}menu{reset}
    '';
  };
}
