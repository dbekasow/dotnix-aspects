{ inputs, ... }:
{
  imports = [ (inputs.import-tree ./desktop) ];
}
