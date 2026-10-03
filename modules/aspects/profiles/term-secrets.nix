# term/secrets after the gnupg move to core: the CLI secret store. gpg-agent
# remains a homeManager.core contribution from the same group — a documented
# cross-pull like fish/git in the core tier.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.term-secrets.imports = with homeManager; [
      rbw
    ];
  };
}
