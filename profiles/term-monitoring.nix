# System monitoring tools.
{ dotnix, ... }: {
  dotnix.home.term-monitoring.includes = with dotnix; [
    bandwhich
    bottom
    fastfetch
    hyperfine
    procs
    rustscan
    tealdeer
    television
    tokei
  ];
}
