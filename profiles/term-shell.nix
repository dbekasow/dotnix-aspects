# Shells without their UX tooling.
{ dotnix, ... }: {
  dotnix.term-shell.includes = with dotnix.home; [ fish nushell ];
}
