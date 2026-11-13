# Office suite and the GUI mail client.
{ dotnix, ... }: {
  dotnix.home.office.includes = with dotnix.home; [
    onlyoffice
    thunderbird
  ];
}
