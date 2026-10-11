{
  dotnix.tmux.homeManager = { config, lib, popup-launcher, ... }:
    let
      launcherKeys = {
        bluetui = "B";
        bottom = "b";
        lazydocker = "d";
        shell = "f";
        lazygit = "g";
        k9s = "k";
        aerc = "m";
        nix-graph = "n";
        gh-dash = "p";
        dua = "u";
        wifitui = "w";
        yazi = "y";
        tv = "t";
        scratch = "S";
      };
      candidates = map
        (launcher: lib.recursiveUpdate launcher {
          key = launcherKeys.${launcher.name};
          command = if launcher.name == "scratch" then "env TMUX= tmux new-session -A -s scratch" else launcher.command;
          directory = if launcher.name == "scratch" then null else "#{pane_current_path}";
        })
        popup-launcher;
      popups = lib.sortOn (p: lib.toLower p.key + p.key) candidates;

      # Candidates omit `directory`; the deleted submodule defaulted it to the current
      # pane path. Scratch keeps its explicit null to avoid pinning a session start dir.
      # Double quotes let tmux expand #{...} at popup time; the single-quoted menu item
      # below defers that expansion past display-menu's parse.
      popupCmd = p:
        let dir = p.directory or "#{pane_current_path}"; in
        lib.concatStringsSep " " (
          [ "display-popup -EE" "-w ${p.width}" "-h ${p.height}" ''-T " ${p.name} "'' ]
          ++ lib.optional (dir != null) ''-d "${dir}"''
          ++ [ ''"${p.command}"'' ]
        );
      menuItem = p: "  \"${p.name}\" ${p.key} '${popupCmd p}'";
      keys = map (p: p.key) popups;
    in
    lib.mkIf config.programs.tmux.enable {
      assertions = [{ assertion = keys == lib.unique keys; message = "Duplicate tmux popup keys: ${lib.concatStringsSep " " keys}"; }];
      programs.tmux.extraConfig = ''
        set -g popup-border-lines rounded
        set -gF popup-border-style "fg=#{@thm_surface_2}"
        bind -N "TUI popups" o display-menu -T " popups " -x C -y C \
        ${lib.concatStringsSep " \\\n" (map menuItem popups)}
      '';
    };
}
