# Terminal profile with Herdr instead of Tmux/Sesh/Zellij.
{ dotnix, ... }: {
  dotnix.home.terminal-herdr.includes = with dotnix.home; [
    term-shell
    term-ux-herdr
    term-cli
    term-monitoring
    term-nix
    term-secrets
  ];
}
