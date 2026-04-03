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
        help = "Rebuild and activate without bootloader";
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
      {
        category = "wsl";
        name = "wsl-tarball";
        help = "Build WSL tarball with embedded SSH host keys for stable agenix-rekey";
        command = ''
          set -euo pipefail

          hostname="''${1:-}"
          if [ -z "$hostname" ]; then
            echo "Usage: wsl-tarball <nixosConfigurations hostname>"
            exit 1
          fi

          extra="$(mktemp -d)"
          trap 'rm -rf "$extra"' EXIT

          # Copy current host keys into extra-files tree
          install -d -m 755 "$extra/etc/ssh"
          sudo cp /etc/ssh/ssh_host_ed25519_key     "$extra/etc/ssh/"
          sudo cp /etc/ssh/ssh_host_ed25519_key.pub "$extra/etc/ssh/"
          sudo chmod 600 "$extra/etc/ssh/ssh_host_ed25519_key"
          sudo chmod 644 "$extra/etc/ssh/ssh_host_ed25519_key.pub"

          echo "=> Host key fingerprint:"
          ssh-keygen -lf "$extra/etc/ssh/ssh_host_ed25519_key.pub"

          echo "=> Building tarball for '$hostname'..."
          sudo nix run \
            ".#nixosConfigurations.''${hostname}.config.system.build.tarballBuilder" \
            -- \
            --extra-files "$extra" \
            --chown /etc/ssh 0:0
        '';
      }
    ];

    devshells.default.devshell.motd = ''
      {147}dotnix{reset} - type {italic}menu{reset} for commands
    '';
  };
}
