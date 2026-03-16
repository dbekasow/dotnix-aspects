{
  flake.modules.homeManager.terminal = {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        # UI Configuration        
        default_layout = "compact";
        pane_frames = false;
        simplified_ui = true;
        ui.pane_frames.hide_session_name = true;
        ui.pane_frames.rounded_corners = true;

        # Performance & Buffer
        scroll_buffer_size = 20000;
        serialize_pane_viewport = false;
        session_serialization = true;

        # Interaction
        copy_on_select = true;
        mouse_mode = true;

        # Interface Cleanliness
        show_startup_tips = false;
        show_release_notes = false;

        # Environment setup
        env.COLORTERM = "truecolor";
      };
    };
  };
}
