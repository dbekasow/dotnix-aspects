{ inputs, ... }:
{
  imports = [
    ../consumer.nix
    (inputs.import-tree ./features/age)
  ];
}
