# Shells without their UX tooling.
{ dotnix, ... }: {
  dotnix.home.term-shell.includes = with dotnix.home; [ fish nushell ];
}
