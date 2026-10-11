{
  dotnix.tmux.homeManager = { config, lib, osConfig ? null, pkgs, ... }:
    let
      inherit (lib) getExe;
      hostFlag = path: osConfig != null && lib.attrByPath path false osConfig;
      candidates = [
        { key = "B"; name = "bluetui"; command = getExe pkgs.bluetui; width = "60%"; height = "55%"; enable = hostFlag [ "hardware" "bluetooth" "enable" ]; }
        { key = "b"; name = "bottom"; command = getExe pkgs.bottom; width = "95%"; height = "90%"; enable = config.programs.bottom.enable or false; }
        { key = "d"; name = "lazydocker"; command = getExe pkgs.lazydocker; width = "90%"; height = "85%"; enable = config.programs.lazydocker.enable or false; }
        { key = "f"; name = "shell"; command = getExe pkgs.fish; width = "80%"; height = "70%"; enable = true; }
        { key = "g"; name = "lazygit"; command = getExe pkgs.lazygit; width = "95%"; height = "90%"; enable = config.programs.lazygit.enable or false; }
        { key = "k"; name = "k9s"; command = getExe pkgs.k9s; width = "95%"; height = "90%"; enable = config.programs.k9s.enable or false; }
        { key = "m"; name = "aerc"; command = getExe pkgs.aerc; width = "90%"; height = "85%"; enable = config.programs.aerc.enable or false; }
        { key = "n"; name = "nix-graph"; command = getExe pkgs.nix-graph; width = "90%"; height = "80%"; enable = true; }
        { key = "p"; name = "gh-dash"; command = getExe pkgs.gh-dash; width = "90%"; height = "80%"; enable = config.programs.gh.enable or false; }
        { key = "u"; name = "dua"; command = "${getExe pkgs.dua} i"; width = "75%"; height = "75%"; enable = true; }
        { key = "w"; name = "wifitui"; command = getExe pkgs.wifitui; width = "60%"; height = "55%"; enable = hostFlag [ "networking" "wireless" "iwd" "enable" ]; }
        { key = "y"; name = "yazi"; command = getExe pkgs.yazi; width = "95%"; height = "90%"; enable = config.programs.yazi.enable or false; }
        { key = "t"; name = "tv"; command = getExe pkgs.television; width = "70%"; height = "60%"; enable = config.programs.television.enable or false; }
        { key = "S"; name = "scratch"; command = "env TMUX= tmux new-session -A -s scratch"; directory = null; width = "90%"; height = "85%"; enable = true; }
      ];
      popups = lib.sortOn (p: lib.toLower p.key + p.key) (lib.filter (p: p.enable) candidates);

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
