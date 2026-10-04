# System monitoring tools.
{ dotnix, ... }: {
  dotnix.term-monitoring.includes = with dotnix; [
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
