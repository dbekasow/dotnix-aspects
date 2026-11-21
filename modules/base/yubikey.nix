{
  imports = [
    ../consumer.nix
    ./features/yubikey/yubikey.nix
    ./features/yubikey/yubikey-pam.nix
  ];
}
