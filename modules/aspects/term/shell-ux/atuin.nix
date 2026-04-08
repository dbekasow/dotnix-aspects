{
  flake.modules.homeManager.atuin = { lib, ... }: {
    programs.atuin = {
      enable = true;

      flags = [ "--disable-up-arrow" ];

      settings = {
        # Privacy
        auto_sync = lib.mkDefault false;
        update_check = false;

        history_filter = [ "^clear$" "^exit$" "^l[salt]" "^y" "^z" ];

        # Search 
        filter_mode = "host";
        filter_mode_shell_up_key_binding = "session";
        store_failed = false;
        workspaces = true;

        # UI
        style = "compact";
        inline_height = 20;
        show_help = false;
        show_tabs = false;
      };
    };
  };
}
