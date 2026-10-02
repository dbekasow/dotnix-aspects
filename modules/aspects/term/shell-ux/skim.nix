{
  flake.modules.homeManager.skim = {
    programs.skim = {
      enable = true;

      # fzf owns the widget bindings; sk stays as the sesh picker backend,
      # which invokes it with explicit flags. With fish integration off,
      # none of the SKIM_* settings would reach it anyway.
      enableFishIntegration = false;
    };
  };
}
