# Composition of the terminal sub-bundles.
{ dotnix, ... }: {
  dotnix.terminal.includes = with dotnix; [
    term-shell
    term-ux
    term-cli
    term-monitoring
    term-nix
    term-secrets
  ];
}
