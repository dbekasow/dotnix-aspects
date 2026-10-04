{
  flake.modules.homeManager.gh = { lib, pkgs, ... }: {
    programs.gh = {
      enable = true;
      # Stacks with dotnix.git.credentials helpers for github.com: git
      # tries credential helpers in order, the first successful one wins.
      gitCredentialHelper.enable = lib.mkDefault true;
      settings = {
        editor = "hx";
        # Store path, not a bare name: bat is installed by the term tier,
        # and this aspect must not depend on that tier for PATH lookup.
        pager = "${lib.getExe pkgs.bat}";
        prompt = "enabled";
      };
    };
    programs.gh-dash.enable = true;
  };

  # Impermanence contribution for gh.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".config/gh" ];
  };
}
