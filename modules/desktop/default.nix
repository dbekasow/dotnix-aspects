{ inputs, ... }:
{
  imports = [ (inputs.import-tree [ ./features ./profiles ]) ];
}
