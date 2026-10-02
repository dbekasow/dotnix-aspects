{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.core.imports = with nixos; [
      age
      age-rekey
      certificates
      # Deliberate work-base from other groups: shell + git + llm-agents —
      # every work profile needs them (tiers are composition layers).
      fish
      git
      home-manager
      llm-agents
      locale
      nh
      nix
      nur
      security
      ssh
      stylix
      system-packages
      users
      users-profile
      # yubikey and yubikey-pam moved to the system tier: pcscd and
      # pam_u2f are workstation hardware, dead weight on headless hosts.
    ];

    homeManager.core.imports = with homeManager; [
      age
      age-rekey
      git
      git-alias
      git-credentials
      git-repos
      gpg-agent
      home-manager
      ssh
      stylix
      users-profile
    ];
  };
}
