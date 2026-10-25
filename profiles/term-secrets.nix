# CLI secret store.
{ dotnix, ... }: {
  dotnix.term-secrets.includes = [ dotnix.home.rbw ];
}
