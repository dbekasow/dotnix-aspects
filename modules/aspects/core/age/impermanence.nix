# Impermanence contribution for age — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.nixos.impermanence = {
    age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };
}
