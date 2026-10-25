{ inputs, ... }:
{
  dotnix.tuicr.homeManager = { config, lib, pkgs, ... }:
    let
      packages = pkgs.llm-agents or inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      inherit (packages) tuicr;
      toml = pkgs.formats.toml { };
      fullname = config.programs.git.settings.user.name or config.home.username;
    in
    {
      config = lib.mkMerge [
        {
          home.packages = [ tuicr ];

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

              # Stamped on local comments; falls back from Git identity to home.username.
              username = fullname;

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
        }
        (lib.mkIf config.programs.tmux.enable {
          programs.tmux.extraConfig = ''
            bind -N "tuicr review" -T prefix r display-popup -EE -w 90% -h 85% -T " tuicr " "${lib.getExe tuicr}"
          '';
        })
      ];
    };
}
