{
  flake.modules.homeManager.workmux = { pkgs, ... }:
    let yaml = pkgs.formats.yaml { }; in
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
    };

  flake.modules.homeManager.tmux = { pkgs, ... }: {
    dotnix.tmux.popups = [{
      key = "a";
      name = "agents";
      command = "${pkgs.llm-agents.workmux}/bin/workmux dashboard";
    }];
  };
}
