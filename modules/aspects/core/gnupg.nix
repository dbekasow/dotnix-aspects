{
  flake.modules.nixos.gnupg = { pkgs, ... }: {
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    # GUI prompting is owned by the HM gpg-agent aspect; system side
    # stays tty-capable.
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;
  };
}
