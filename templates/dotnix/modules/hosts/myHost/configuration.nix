{
  # Register the host under the dotnix.hosts registry.
  dotnix.hosts.myHost = { nixos, ... }: {
    modules = with nixos; [
      dell-precision-5570 # from ./hardware.nix
      core # home-manager wiring (nixos.home-manager) — the factory does NOT inject it
      desktop-shell # graphical socket; shell and greeter are per-host choices
      dms # shell — swap for `noctalia` to run the alternative
      dms-greeter # greeter — swap for `noctalia-greeter`
      system # boot, disko, network, etc.
      development
      {
        # Throwaway master identity so a fresh clone evaluates and `agenix`
        # demos against a key nobody holds. Replace before going live.
        age.rekey.masterIdentities = [
          { identity = ./secrets/masterkey.age; pubkey = "age178wfu8598yp9vgcq3c5vwfmvtsqncypd0gkmal873yzl0y8zq5ls07q2cz"; }
        ];
      }
    ];
    # must match the user aspect name in modules/users/<user>/default.nix
    members = [ "myuser" ];
  };
}
