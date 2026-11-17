# Optional laptop-oriented bundle; consumers may select its aspects individually.
{ dotnix, ... }: {
  dotnix.host.workstation.includes = with dotnix.host; [
    boot-baseline
    bluetooth
    network
    network-wifi
    pipewire
    power
  ];
}
