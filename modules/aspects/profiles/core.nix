{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.core = {
      imports = with nixos; [
        age
        age-rekey
        certificates
        # Deliberate work-base from other groups: shell + git —
        # every work profile needs them (tiers are composition layers).
        fish
        git
        # System GnuPG agent beside the HM gpg-agent in homeManager.core
        # (see below) — keeps the pinentry pairing visible in one tier.
        gnupg
        home-manager
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

      # The core tier owns its user-side counterpart: hosts importing
      # nixos.core get homeManager.core for every user. The coupling was
      # hard-wired in the home-manager aspect (invisible wiring); declared
      # here it stays visible in the tier and individually overridable by
      # any host module.
      home-manager.sharedModules = [ homeManager.core ];
    };

    homeManager.core.imports = with homeManager; [
      age
      age-rekey
      git
      git-alias
      git-credentials
      git-repos
      gpg-agent
      ssh
      stylix
      users-profile
    ];
  };
}
