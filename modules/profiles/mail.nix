# Mail stays separate from general terminal features.
{ dotnix, ... }: {
  dotnix.home.mail.includes = with dotnix.home; [ aerc maildir ];
}
