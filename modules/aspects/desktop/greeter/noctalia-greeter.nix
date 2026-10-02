{ inputs, ... }: {
  # greetd greeter with its own wlroots mini-compositor — no compositor
  # session needed at login time. One greeter per host: dms-greeter and
  # noctalia-greeter both claim greetd's default session, so importing
  # both fails the option merge instead of half-booting.
  flake.modules.nixos.noctalia-greeter = {
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    services.displayManager.noctalia-greeter.enable = true;
  };
}
