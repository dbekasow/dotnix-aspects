{ dotnix, ... }:
{
  dotnix.popup-launchers.popup-launcher =
    { config
    , lib
    , osConfig ? null
    , pkgs
    , ...
    }:
    let
      hostFlag = path: osConfig != null && lib.attrByPath path false osConfig;
      withPrograms = config.programs;
      candidates = [
        { name = "bluetui"; command = lib.getExe pkgs.bluetui; width = "60%"; height = "55%"; keys = { tmux = "B"; herdr = "prefix+shift+b"; }; enable = hostFlag [ "hardware" "bluetooth" "enable" ]; }
        { name = "bottom"; command = lib.getExe pkgs.bottom; width = "95%"; height = "90%"; keys = { tmux = "b"; herdr = "prefix+alt+b"; }; enable = withPrograms.bottom.enable or false; }
        { name = "lazydocker"; command = lib.getExe pkgs.lazydocker; width = "90%"; height = "85%"; keys = { tmux = "d"; herdr = "prefix+d"; }; enable = withPrograms.lazydocker.enable or false; }
        { name = "shell"; command = lib.getExe pkgs.fish; width = "80%"; height = "70%"; keys = { tmux = "f"; herdr = "prefix+f"; }; enable = true; }
        { name = "lazygit"; command = lib.getExe pkgs.lazygit; width = "95%"; height = "90%"; keys = { tmux = "g"; herdr = "prefix+alt+g"; }; enable = withPrograms.lazygit.enable or false; }
        { name = "k9s"; command = lib.getExe pkgs.k9s; width = "95%"; height = "90%"; keys = { tmux = "k"; herdr = "prefix+alt+k"; }; enable = withPrograms.k9s.enable or false; }
        { name = "aerc"; command = lib.getExe pkgs.aerc; width = "90%"; height = "85%"; keys = { tmux = "m"; herdr = "prefix+m"; }; enable = withPrograms.aerc.enable or false; }
        { name = "nix-graph"; command = lib.getExe pkgs.nix-graph; width = "90%"; height = "80%"; keys = { tmux = "n"; herdr = "prefix+alt+n"; }; enable = true; }
        { name = "gh-dash"; command = lib.getExe pkgs.gh-dash; width = "90%"; height = "80%"; keys = { tmux = "p"; herdr = "prefix+alt+p"; }; enable = (withPrograms.gh.enable or false) || (withPrograms.gh-dash.enable or false); }
        { name = "dua"; command = "${lib.getExe pkgs.dua} i"; width = "75%"; height = "75%"; keys = { tmux = "u"; herdr = "prefix+u"; }; enable = true; }
        { name = "wifitui"; command = lib.getExe pkgs.wifitui; width = "60%"; height = "55%"; keys = { tmux = "w"; herdr = "prefix+alt+w"; }; enable = hostFlag [ "networking" "wireless" "iwd" "enable" ]; }
        { name = "yazi"; command = lib.getExe pkgs.yazi; width = "95%"; height = "90%"; keys = { tmux = "y"; herdr = "prefix+y"; }; enable = withPrograms.yazi.enable or false; }
        { name = "tv"; command = lib.getExe pkgs.television; width = "70%"; height = "60%"; keys = { tmux = "t"; herdr = "prefix+t"; }; enable = withPrograms.television.enable or false; }
        { name = "scratch"; command = lib.getExe pkgs.fish; width = "90%"; height = "85%"; keys = { tmux = "S"; herdr = "prefix+shift+s"; }; enable = true; }
      ];
    in
    map
      (launcher: lib.filterAttrs (name: _: name != "enable") launcher)
      (lib.filter (launcher: launcher.enable) candidates);

  dotnix.tmux.includes = [ dotnix.popup-launchers ];
  dotnix.herdr.includes = [ dotnix.popup-launchers ];
}
