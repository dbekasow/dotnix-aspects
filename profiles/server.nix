# Headless composition without workstation network, audio or power defaults.
{ dotnix, ... }: {
  dotnix.host.server.includes = [ dotnix.host.base ];
}
