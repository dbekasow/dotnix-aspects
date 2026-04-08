{
  flake.modules.homeManager.lazygit = {
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
