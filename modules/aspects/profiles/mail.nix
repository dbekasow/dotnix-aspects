# Mail as its own tier on purpose: hosts that do not mail never pull
# aerc/maildir — mailing is a workflow, not terminal furniture.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.mail.imports = with homeManager; [
      aerc
      maildir
    ];
  };
}
