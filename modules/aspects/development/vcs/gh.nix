{
  flake.modules.homeManager.development = { config, ... }: {
    age.secrets.github-ssh-key = {
      generator.script = "ssh-ed25519";
      mode = "600";
    };

    programs.ssh.matchBlocks."github.com" = {
      identityFile = config.age.secrets.github-ssh-key.path;
      identitiesOnly = true;
    };

    programs.gh-dash.enable = true;
    programs.gh = {
      enable = true;
      settings = {
        editor = "hx";
        git_protocol = "ssh";
        pager = "bat";
        prompt = "enabled";
      };
    };
  };
}
