{
  flake.modules.homeManager.television = { lib, pkgs, ... }: {
    programs.television = {
      enable = true;

      channels = {
        zoxide = let zoxide = lib.getExe pkgs.zoxide; in {
          metadata = { name = "zoxide"; description = "Browse zoxide history"; };
          source = { command = "${zoxide} query --list"; no_sort = true; frecency = false; };
          keybindings = { enter = "actions:cd"; };
          actions.cd = {
            command = "cd '{}' && $SHELL";
            mode = "execute";
          };
        };

        tldr = let tldr = lib.getExe pkgs.tealdeer; in {
          metadata = { name = "tldr"; description = "Browse and preview TLDR help pages"; };
          source.command = "${tldr} --list";
          preview.command = "${tldr} '{0}' --color always";
          keybindings.ctrl-e = "actions:open";
          actions.open = {
            command = "${tldr} '{0}'";
            mode = "execute";
          };
        };
      };
    };
  };
}
