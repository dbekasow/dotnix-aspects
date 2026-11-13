{
  dotnix.home.tmux.homeManager = { config, lib, osConfig ? null, popup-launcher, ... }:
    let
      # `enable` gates are closures from features/popup-launchers.nix; they
      # must run here, where `config` is the user's home-manager config.
      candidates = lib.concatMap
        (launcher:
          let
            key = lib.attrByPath [ "keys" "tmux" ] null launcher;
          in
          if key == null then
            builtins.trace
              "dotnix.home.tmux: omitting popup launcher '${launcher.name}' because it has no `keys.tmux` binding; add one to its record in features/popup-launchers.nix."
              [ ]
          else if !(launcher.enable { inherit config osConfig; }) then
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
