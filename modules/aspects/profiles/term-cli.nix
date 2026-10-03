# term/files + term/data as one HM tier: the modern coreutils replacements
# share one profile concern (daily file and data wrangling), `terminal`
# composes it.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.term-cli.imports = with homeManager; [
      bat
      dua
      dust
      eza
      fd
      ouch
      ripgrep
      ripgrep-all
      sd
      fx
      jq
      mdcat
      xh
    ];
  };
}
