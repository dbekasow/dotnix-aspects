{
  flake.modules.homeManager.development = {
    programs.lazygit = {
      enable = true;

      settings.gui = {
        expandFocusedSidePanel = true;
        showBottomLine = false;
        showCommandLog = false;
      };
    };
  };
}
