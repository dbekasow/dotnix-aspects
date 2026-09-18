let
  # Called from both modules below with the same inputs, so both get the same store path.
  mkPicker = { config, lib, pkgs }:
    let
      # -d: a repo that is both a configured session and a zoxide entry shows once.
      # -H: the current session is useless as a target.
      list = "sesh list --icons -d -H";

      # List order is header order.
      modes = [
        { key = "a"; icon = "⚡"; label = "all"; cmd = list; }
        { key = "t"; icon = "🪟"; label = "tmux"; cmd = "${list} -t"; }
        { key = "g"; icon = "⚙️"; label = "configs"; cmd = "${list} -c"; }
        { key = "x"; icon = "📁"; label = "zoxide"; cmd = "${list} -z"; }
        { key = "f"; icon = "🔎"; label = "find"; cmd = "fd -H -d 2 -t d -E .Trash . ~"; }
      ];
      header = lib.concatMapStringsSep "  " (m: "${m.icon} ^${m.key} ${m.label}") modes;
      binds = lib.concatMapStringsSep "," (m: "ctrl-${m.key}:reload(${m.cmd})") modes;
    in
    pkgs.writeShellApplication {
      name = "sesh-picker";
      # sesh shells out to tmux and zoxide itself, so they need to be on PATH too.
      runtimeInputs = with config.programs; [ sesh.package skim.package tmux.package pkgs.zoxide pkgs.fd ];
      text = ''
        # Esc or no match exits quietly instead of running `sesh connect ""`.
        selection=$(${list} | sk --ansi --no-sort --height 100% \
          --header '${header} ^d kill' \
          --bind 'tab:down,btab:up,${binds}' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+reload(${list})' \
          --preview 'sesh preview {}' --preview-window right:55%) || exit 0
        exec sesh connect "$selection"
      '';
    };
in
{
  flake.modules.homeManager.sesh = { config, lib, pkgs, ... }: {
    programs.sesh = {
      enable = true;

      # Both built-ins break on an aborted picker; sesh-picker replaces them.
      enableAlias = false;
      enableTmuxIntegration = false;

      settings = {
        default_session.preview_command = "eza --tree --icons --color=always --level 2 {}";

        # Every repo declared via dotnix.git.repositories becomes a named
        # session, so sesh lists them before they have ever been opened.
        session = lib.mapAttrsToList
          (dest: _: { name = baseNameOf dest; path = "${config.home.homeDirectory}/${dest}"; })
          config.dotnix.git.repositories;
      };
    };

    home.packages = [ (mkPicker { inherit config lib pkgs; }) ];
    programs.fish.shellAbbrs.s = "sesh-picker";

    programs.fish.interactiveShellInit = ''
      if not set -q TMUX
        ${lib.getExe config.programs.sesh.package} connect (pwd)
      end
    '';
  };

  flake.modules.homeManager.tmux = { config, lib, pkgs, ... }:
    let
      sesh = lib.getExe config.programs.sesh.package;
      picker = lib.getExe (mkPicker { inherit config lib pkgs; });
    in
    {
      # The popup gives sk a real TTY; -EE closes it whatever the exit status.
      dotnix.tmux.bindings = map
        (base: base // { inherit (config.programs.sesh) enable; }) [
        { key = "s"; name = "Sesh picker"; command = ''display-popup -EE -w 80% -h 70% -T " sesh " "${picker}"''; }
        { key = "S"; name = "Last session"; command = ''run-shell "${sesh} last"''; }
      ];
    };
}
