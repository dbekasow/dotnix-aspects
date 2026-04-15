{
  # Register host under the dotnix namespace.
  dotnix.myHost = { nixos, ... }: {
    modules = with nixos; [
      dell-precision-5570
      system # boot, disko, network, etc.
      development
    ];
    members = [ "myUser" ];
  };
}
