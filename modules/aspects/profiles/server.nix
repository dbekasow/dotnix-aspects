# Headless composition without workstation network, audio or power defaults.
{ dotnix, ... }: {
  dotnix.server.includes = [ dotnix.base ];
}
