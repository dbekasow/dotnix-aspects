_: {
  dotnix.account.users.user = { lib, ... }: {
    isNormalUser = lib.mkDefault true;
  };
}
