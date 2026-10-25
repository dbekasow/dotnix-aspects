# Optional laptop-oriented bundle; consumers may select its aspects individually.
{ dotnix, ... }: {
  dotnix.host.workstation.includes = with dotnix.host; [
    boot
    journald
    boot-systemd
    performance
    bluetooth
    disko
    persistence
    btrfs-root-reset
    geolocation
    network
    network-wifi
    pipewire
    power
    yubikey
  ];
}
