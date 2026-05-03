{
  flake.modules.homeManager.gh = {
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        editor = "hx";
        pager = "bat";
        prompt = "enabled";
      };
    };
    programs.gh-dash.enable = true;
  };
}
