{
  flake.modules.nixos.core = {
    age.generators.ssh-rsa-4096 = { pkgs, ... }: ''
      ${pkgs.openssh}/bin/ssh-keygen \
        -t rsa-sha2-512 \
        -b 4096 \
        -C "agenix" \
        -N "" \
        -f /dev/stdout 2>/dev/null
    '';
  };

  flake.modules.homeManager.core = { osConfig, ... }: {
    age.generators.ssh-rsa-4096 = osConfig.age.generators.ssh-rsa-4096;
  };
}
