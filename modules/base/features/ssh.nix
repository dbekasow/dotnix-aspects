{
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
