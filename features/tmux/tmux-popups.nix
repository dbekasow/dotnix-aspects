{
  dotnix.tmux.homeManager = { config, lib, popup-launcher, ... }:
    let
      candidates = lib.concatMap
        (launcher:
          let
            key = lib.attrByPath [ "keys" "tmux" ] null launcher;
          in
          if key == null then
            builtins.trace
              "dotnix.tmux: omitting popup launcher '${launcher.name}' because it has no `keys.tmux` binding; add one to its record in features/popup-launchers.nix."
              [ ]
          else
            [
              (lib.recursiveUpdate launcher {
                inherit key;
                command = if launcher.name == "scratch" then "env TMUX= tmux new-session -A -s scratch" else launcher.command;
                directory = if launcher.name == "scratch" then null else "#{pane_current_path}";
              })
            ])
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
