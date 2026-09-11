{ inputs, ... }: {
  flake.modules.nixos.nix = { lib, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        accept-flake-config = true;
        builders-use-substitutes = true;

        # Was true: runs a full hardlink-dedup pass over the entire store,
        # under lock, after EVERY build and EVERY substitute download. The
        # weekly optimise.automatic timer below already does the same thing
        # — once instead of a hundred times.
        auto-optimise-store = false;

        experimental-features = [ "nix-command" "flakes" ];

        keep-outputs = lib.mkDefault false;
        keep-derivations = lib.mkDefault false;

        allowed-users = [ "@wheel" ];
        trusted-users = [ "root" "@wheel" ];

        # Five substituters over a flaky WLAN: without timeouts Nix can hang
        # for minutes on a poorly reachable cache. fallback=true builds
        # locally instead of dying on a dead cache.
        connect-timeout = 5;
        stalled-download-timeout = 20;
        download-attempts = 3;
        fallback = true;
        http-connections = 50;
        narinfo-cache-negative-ttl = 30;
      };

      # Keeps a background rebuild invisible instead of blocking the desktop.
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;

      package = pkgs.nixVersions.latest;
      registry.nixpkgs.flake = inputs.nixpkgs;
      optimise.automatic = true;
      channel.enable = false;
    };

    system.activationScripts.removeNixChannels.text = ''
      rm -rf /root/.nix-defexpr/channels
      rm -rf /nix/var/nix/profiles/per-user/root/channels
    '';
  };

  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".directories = [
      "/etc/nixos"
      "/var/lib/nixos"
      "/var/lib/systemd"
    ];
  };
}
