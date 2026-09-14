{
  flake.modules.homeManager.clipboard = { lib, pkgs, ... }: {
    home.packages = with pkgs; [ wl-clipboard ];

    programs.fish.functions =
      let
        clip = lib.getExe' pkgs.wl-clipboard;
        wrap = cmd: { body = "${clip cmd} $argv"; wraps = cmd; };
      in
      {
        copy = wrap "wl-copy";
        paste = wrap "wl-paste";
      };
  };
}
