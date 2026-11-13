# Shared boot and journald behavior without choosing a bootloader or root disk.
{ dotnix, ... }: {
  dotnix.host.boot-baseline.includes = [ dotnix.host.boot dotnix.host.journald ];
}
