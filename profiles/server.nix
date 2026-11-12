# Headless composition without workstation network, audio or power defaults.
{ dotnix, ... }: {
  dotnix.host.server.includes = with dotnix.host; [ base ssh security ];
}
