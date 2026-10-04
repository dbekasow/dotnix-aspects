{
  flake.modules.nixos.ssh = { lib, pkgs, ... }: {
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

  flake.modules.homeManager.ssh = {
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

  # Impermanence contribution for ssh.
  # Host keys on the nixos side, the per-user ~/.ssh on the homeManager side.
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
