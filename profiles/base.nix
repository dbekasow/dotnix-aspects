# Shared boot and journald behavior without choosing a bootloader or root disk.
{ dotnix, ... }: {
  dotnix.host.base.includes = [ dotnix.host.boot dotnix.host.journald ];
}
