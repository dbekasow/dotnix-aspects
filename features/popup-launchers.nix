{ dotnix, ... }:
{
  # The pipe crosses den's producer scope, where `config` is the HOST config,
  # not the consuming user's home-manager config — evaluating programs.*.enable
  # here silently dropped every conditional launcher (2026-11). `enable` is
  # therefore a closure the consumer calls with ITS config and osConfig.
  dotnix.popup-launchers.popup-launcher =
    { lib
    , pkgs
    , ...
    }:
    let
      # { config, osConfig ? null } -> bool, evaluated consumer-side where the
      # user's home-manager config is the real fixpoint.
      gate =
        { always ? false
        , program ? null
        , hostFlag ? null
        , any ? [ ]
        }:
        { config, osConfig ? null }:
        if always then true
        else if program != null then config.programs.${program}.enable or false
        else if hostFlag != null then osConfig != null && lib.attrByPath hostFlag false osConfig
        else lib.any (g: g { inherit config osConfig; }) (map gate any);
      candidates = [
        { name = "bluetui"; command = lib.getExe pkgs.bluetui; width = "60%"; height = "55%"; keys = { tmux = "B"; herdr = "prefix+shift+b"; }; enable = gate { hostFlag = [ "hardware" "bluetooth" "enable" ]; }; }
        { name = "bottom"; command = lib.getExe pkgs.bottom; width = "95%"; height = "90%"; keys = { tmux = "b"; herdr = "prefix+alt+b"; }; enable = gate { program = "bottom"; }; }
        { name = "lazydocker"; command = lib.getExe pkgs.lazydocker; width = "90%"; height = "85%"; keys = { tmux = "d"; herdr = "prefix+alt+d"; }; enable = gate { program = "lazydocker"; }; }
        { name = "shell"; command = lib.getExe pkgs.fish; width = "80%"; height = "70%"; keys = { tmux = "f"; herdr = "prefix+f"; }; enable = gate { always = true; }; }
        { name = "lazygit"; command = lib.getExe pkgs.lazygit; width = "95%"; height = "90%"; keys = { tmux = "g"; herdr = "prefix+alt+g"; }; enable = gate { program = "lazygit"; }; }
        { name = "k9s"; command = lib.getExe pkgs.k9s; width = "95%"; height = "90%"; keys = { tmux = "k"; herdr = "prefix+alt+k"; }; enable = gate { program = "k9s"; }; }
        { name = "aerc"; command = lib.getExe pkgs.aerc; width = "90%"; height = "85%"; keys = { tmux = "m"; herdr = "prefix+m"; }; enable = gate { program = "aerc"; }; }
        { name = "nix-graph"; command = lib.getExe pkgs.nix-graph; width = "90%"; height = "80%"; keys = { tmux = "n"; herdr = "prefix+alt+n"; }; enable = gate { always = true; }; }
        { name = "gh-dash"; command = lib.getExe pkgs.gh-dash; width = "90%"; height = "80%"; keys = { tmux = "p"; herdr = "prefix+alt+p"; }; enable = gate { any = [{ program = "gh"; } { program = "gh-dash"; }]; }; }
        { name = "dua"; command = "${lib.getExe pkgs.dua} i"; width = "75%"; height = "75%"; keys = { tmux = "u"; herdr = "prefix+u"; }; enable = gate { always = true; }; }
        { name = "wifitui"; command = lib.getExe pkgs.wifitui; width = "60%"; height = "55%"; keys = { tmux = "w"; herdr = "prefix+alt+w"; }; enable = gate { hostFlag = [ "networking" "wireless" "iwd" "enable" ]; }; }
        { name = "yazi"; command = lib.getExe pkgs.yazi; width = "95%"; height = "90%"; keys = { tmux = "y"; herdr = "prefix+y"; }; enable = gate { program = "yazi"; }; }
        { name = "tv"; command = lib.getExe pkgs.television; width = "70%"; height = "60%"; keys = { tmux = "t"; herdr = "prefix+t"; }; enable = gate { program = "television"; }; }
        { name = "scratch"; command = lib.getExe pkgs.fish; width = "90%"; height = "85%"; keys = { tmux = "S"; herdr = "prefix+shift+s"; }; enable = gate { always = true; }; }
      ];
    in
    candidates;

  dotnix.home.tmux.includes = [ dotnix.popup-launchers ];
  dotnix.home.herdr.includes = [ dotnix.popup-launchers ];
}
