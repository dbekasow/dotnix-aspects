{
  flake.modules.homeManager.gh = { lib, ... }: {
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = lib.mkDefault true;
      settings = {
        editor = "hx";
        pager = "bat";
        prompt = "enabled";
      };
    };
    programs.gh-dash.enable = true;
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".config/gh" ];
  };
}
