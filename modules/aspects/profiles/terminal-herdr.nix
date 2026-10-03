# Terminal profile with Herdr instead of Tmux/Sesh/Zellij.
{ self, ... }: {
  flake.modules.homeManager.terminal-herdr.imports = with self.modules.homeManager; [
    term-shell
    term-ux-herdr
    term-cli
    term-monitoring
    term-nix
    term-secrets
  ];
}
