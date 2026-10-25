# Mail stays separate from general terminal features.
{ dotnix, ... }: {
  dotnix.mail.includes = with dotnix; [ aerc maildir ];
}
