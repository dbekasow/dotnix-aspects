# CLI file and data tools.
{ dotnix, ... }: {
  dotnix.home.term-cli.includes = with dotnix; [
    bat
    dua
    dust
    eza
    fd
    ouch
    ripgrep
    ripgrep-all
    sd
    fx
    jq
    mdcat
    xh
  ];
}
