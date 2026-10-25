# Nix development tools.
{ dotnix, ... }: {
  dotnix.term-nix.includes = with dotnix; [ nix-index-database nix-tools nix-search-tv ];
}
