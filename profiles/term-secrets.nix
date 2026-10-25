# CLI secret store.
{ dotnix, ... }: {
  dotnix.home.term-secrets.includes = [ dotnix.home.rbw ];
}
