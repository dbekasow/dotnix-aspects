{ inputs, ... }: {
  flake.modules.nixos.nur = {
    imports = [ inputs.nur.modules.nixos.default ];
  };
}
