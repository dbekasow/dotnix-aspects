# Impermanence contribution for bluetooth — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];
  };
}
