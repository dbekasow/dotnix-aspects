{
  flake.modules.nixos.gnupg = { pkgs, ... }: {
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;
  };
}
