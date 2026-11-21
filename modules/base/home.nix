{ inputs, ... }:
{
  imports = [
    ../system
    (inputs.import-tree.matchNot "/(age|yubikey)/.*" ./features)
    (inputs.import-tree ./profiles)
  ];

  den.quirks.popup-launcher = {
    description = "Enabled popup launcher records shared by selected user-scope aspects";
  };
}
