{ inputs, ... }: {
  flake-file.inputs.noctalia-greeter = {
    url = "github:noctalia-dev/noctalia-greeter/v1.6.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # greetd greeter with its own wlroots mini-compositor — no compositor
  # session needed at login time. One greeter per host: dms-greeter and
  # noctalia-greeter both claim greetd's default session, so importing
  # both fails the option merge instead of half-booting.
  dotnix.noctalia-greeter.nixos = {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    services.displayManager.noctalia-greeter.enable = true;
  };
}
