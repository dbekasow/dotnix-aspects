# Shared boot and journald behavior without choosing a bootloader or root disk.
{ dotnix, ... }: {
  dotnix.base.includes = [ dotnix.boot dotnix.journald ];
}
