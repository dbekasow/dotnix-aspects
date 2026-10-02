# Impermanence contribution for dms-greeter — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".directories = [ "/var/lib/dms-greeter" ];
  };
}
