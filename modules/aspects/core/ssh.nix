{
  flake.modules.nixos.core = { lib, pkgs, ... }: {
    services.openssh = {
      enable = lib.mkDefault true;

      settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault false;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = [ pkgs.openssh ];
  };

  flake.modules.homeManager.core = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks."*" = {
        addKeysToAgent = "yes";
        compression = false;
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "10m";
        forwardAgent = false;
        hashKnownHosts = false;
        serverAliveCountMax = 3;
        serverAliveInterval = 60;
        userKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
