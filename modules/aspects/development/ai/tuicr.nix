{
  flake.modules.homeManager.tuicr = { config, pkgs, ... }:
    let
      toml = pkgs.formats.toml { };
      inherit (config.profile) fullname;
    in
    {
      home.packages = [ pkgs.llm-agents.tuicr ];

      xdg = {
        configFile."tuicr/config.toml".source = toml.generate "tuicr.toml" {
          # Same palette as stylix and the tmux status line.
          theme = "catppuccin-mocha";

          # Mirrors the rest of the review stack: delta renders side-by-side,
          # helix uses relative numbers and scrolloff 8.
          diff_view = "side-by-side";
          relative_line_numbers = true;
          scroll_offset = 8;
          wrap = false;

          # Modal editing in the comment box — same muscle memory as helix.
          comment_vim = true;

          # `editor` is deliberately unset: it falls back to $EDITOR, which
          # programs.helix.defaultEditor already points at hx.

          # Nix owns the binary, so an update prompt can only ever be wrong.
          no_update_check = true;

          # Stamped on local comments; profile.fullname is optional.
          username = if fullname != null then fullname else config.home.username;

          comment_types = [
            { id = "issue"; definition = "must fix before merge"; color = "red"; }
            { id = "suggestion"; definition = "possible improvement"; color = "yellow"; }
            { id = "nit"; label = "nitpick"; definition = "small, optional"; color = "#d19a66"; }
            { id = "praise"; definition = "worth keeping"; color = "green"; }
          ];

          export.intro = "Review from a local tuicr session. Please address the comments below.";
        };
      };

      programs.fish.shellAbbrs.cr = "tuicr";
    };

  flake.modules.homeManager.tmux = { lib, pkgs, ... }: {
    dotnix.tmux.popups = [{
      key = "r";
      name = "tuicr";
      command = lib.getExe pkgs.llm-agents.tuicr;
    }];
  };
}
