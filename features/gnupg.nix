{
  dotnix.host.gnupg.nixos = { lib, pkgs, ... }: {
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    # Host-side prompting stays tty-capable; consumers may override this
    # native option when their host needs another pinentry.
    programs.gnupg.agent.pinentryPackage = lib.mkDefault pkgs.pinentry-curses;
  };
}
