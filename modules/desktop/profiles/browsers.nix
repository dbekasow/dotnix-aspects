# Browser suite.
{ dotnix, ... }: {
  dotnix.home.browsers.includes = [ dotnix.home.firefox ];
}
