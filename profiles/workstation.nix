# Optional laptop-oriented bundle; consumers may select its aspects individually.
{ dotnix, ... }: {
  dotnix.workstation.includes = with dotnix; [
    host.boot
    host.journald
    host.boot-systemd
    host.performance
    host.bluetooth
    host.disko
    host.persistence
    host.btrfs-root-reset
    host.geolocation
    host.network
    host.network-wifi
    host.pipewire
    host.power
    yubikey
    yubikey-pam
  ];
}
