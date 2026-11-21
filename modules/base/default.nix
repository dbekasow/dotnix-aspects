{ inputs, ... }:
{
  imports = [
    ../system
    (inputs.import-tree [ ./features ./profiles ])
  ];

  den.quirks.popup-launcher = {
    description = "Enabled popup launcher records shared by selected user-scope aspects";
  };
}
