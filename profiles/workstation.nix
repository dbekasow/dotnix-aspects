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
    host.pipewire
    power
    yubikey
    yubikey-pam
  ];
}
