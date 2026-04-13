{
  flake.modules.homeManager.gh = {
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = false;
      settings = {
        editor = "hx";
        pager = "bat";
        prompt = "enabled";
      };
    };
    programs.gh-dash.enable = true;
  };
}
