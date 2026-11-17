# Nix development tools.
{ dotnix, ... }: {
  dotnix.home.term-nix.includes = with dotnix.home; [ nix-index-database nix-tools nix-search-tv ];
}
