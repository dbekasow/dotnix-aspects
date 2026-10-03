{
  flake.modules.homeManager.workmux = { config, lib, options, pkgs, ... }:
    let yaml = pkgs.formats.yaml { }; in
    {
      config = lib.mkMerge [
        {
          home.packages = [ pkgs.llm-agents.workmux ];

          # Global defaults. A project's .workmux.yaml still overrides these, and
          # `panes` there replaces this list entirely rather than merging.
          #
          # nerdfont is set explicitly because workmux asks for it on first run
          # and writes the answer back into this file — which is a read-only
          # store symlink here.
          xdg.configFile."workmux/config.yaml".source = yaml.generate "workmux.yaml" {
            nerdfont = true;
            agent = "pi";
            merge_strategy = "rebase";
            base_branch = "auto";

            panes = [
              { command = "<agent>"; focus = true; }
              { split = "horizontal"; }
            ];
          };

          programs.fish.shellAbbrs.wx = "workmux";
        }
        (lib.optionalAttrs (options ? dotnix.tmux.popups && options ? dotnix.tmux.bindings) {
          dotnix.tmux.popups = lib.mkIf config.programs.tmux.enable [
            { key = "a"; name = "agents"; command = "${pkgs.llm-agents.workmux}/bin/workmux dashboard"; }
          ];

          # Not a popup: the sidebar adds a real pane to every window, so it has
          # to run against the server rather than inside an overlay. The command
          # toggles on its own, one key covers both directions.
          dotnix.tmux.bindings = lib.mkIf config.programs.tmux.enable [
            { key = "a"; name = "Agent sidebar"; command = ''run-shell "${pkgs.llm-agents.workmux}/bin/workmux sidebar"''; }
            { key = "A"; name = "Agent sidebar (session)"; command = ''run-shell "${pkgs.llm-agents.workmux}/bin/workmux sidebar --session"''; }
          ];
        })
      ];
    };
}
