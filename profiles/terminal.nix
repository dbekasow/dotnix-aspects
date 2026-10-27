# Composition of the terminal sub-bundles.
{ dotnix, ... }: {
  dotnix.home.terminal.includes = with dotnix.home; [
    term-shell
    term-ux
    term-cli
    term-monitoring
    term-nix
    term-secrets
  ];
}
