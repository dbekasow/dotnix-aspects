# Impermanence contribution for ssh — collector pattern: the entries
# live with the contributing feature, not in the impermanence collector.
# Host keys on the nixos side, the per-user ~/.ssh on the homeManager side.
{
  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".files = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".ssh" ];
  };
}
