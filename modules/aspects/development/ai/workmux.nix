{
  dotnix.workmux.homeManager = { config, lib, pkgs, ... }:
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
        (lib.mkIf config.programs.tmux.enable {
          programs.tmux.extraConfig = ''
            bind -N "Agent sidebar" a run-shell "${pkgs.llm-agents.workmux}/bin/workmux sidebar"
            bind -N "Agent sidebar (session)" A run-shell "${pkgs.llm-agents.workmux}/bin/workmux sidebar --session"
            # Prefix o belongs to the TUI popups menu; keep this one on w so both
            # menus stay reachable when development and terminal are selected together.
            bind -N "agents" -T prefix w display-menu -T " agents " -x C -y C "Dashboard" a "display-popup -EE -w 90% -h 85% -T ' agents ' '${pkgs.llm-agents.workmux}/bin/workmux dashboard'"
          '';
        })
      ];
    };
}
