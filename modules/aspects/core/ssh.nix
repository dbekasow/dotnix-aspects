{
  flake.modules.nixos.ssh = { lib, pkgs, ... }: {
    services.openssh = {
      enable = lib.mkDefault true;

      settings = {
        PermitRootLogin = lib.mkForce "prohibit-password";
        PasswordAuthentication = lib.mkDefault false;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = [ pkgs.openssh ];
  };

  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings."*" = {
        AddKeysToAgent = "yes";
        Compression = "no";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "10m";
        ForwardAgent = "no";
        HashKnownHosts = "no";
        ServerAliveCountMax = 3;
        ServerAliveInterval = 60;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };

  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".files = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".ssh" ];
  };
}
