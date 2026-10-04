# Terminal profile with Herdr instead of Tmux/Sesh/Zellij.
{ dotnix, ... }: {
  dotnix.terminal-herdr.includes = with dotnix; [
    term-shell
    term-ux-herdr
    term-cli
    term-monitoring
    term-nix
    term-secrets
  ];
}
