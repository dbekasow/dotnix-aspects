# Optional laptop-oriented bundle; consumers may select its aspects individually.
{ dotnix, ... }: {
  dotnix.workstation.includes = with dotnix; [
    boot
    journald
    boot-systemd
    performance
    bluetooth
    disko
    impermanence
    geolocation
    network
    network-wifi
    pipewire
    power
    yubikey
    yubikey-pam
  ];
}
