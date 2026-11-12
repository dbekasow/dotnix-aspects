# Shells without their UX tooling.
{ dotnix, ... }: {
  dotnix.home.shells.includes = with dotnix.home; [ fish nushell ];
}
