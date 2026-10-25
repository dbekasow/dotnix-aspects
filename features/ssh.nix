{
  dotnix.host.ssh = {
    nixos = { lib, pkgs, ... }: {
      services.openssh = {
        enable = lib.mkDefault true;

        settings = {
          # "prohibit-password" is the upstream default, so no explicit
          # PermitRootLogin — hosts stay free to tighten it to "no".
          PasswordAuthentication = lib.mkDefault false;
        };
      };

      # Port 22 is opened by services.openssh.openFirewall (default true).

      environment.systemPackages = [ pkgs.openssh ];
    };

    # Host keys on the NixOS side.
    systemPersistence = {
      environment.persistence."/persist".files = [
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };
  };

  dotnix.home.ssh = {
    homeManager = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings."*" = {
          AddKeysToAgent = "yes";
          ControlMaster = "auto";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "10m";
          ServerAliveInterval = 60;
        };
      };
    };

    # The per-user ~/.ssh directory.
    homePersistence = {
      home.persistence."/persist".directories = [ ".ssh" ];
    };
  };
}
