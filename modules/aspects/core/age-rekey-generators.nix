{
  flake.modules.nixos.core = {
    age.generators.ssh-rsa-4096 = { pkgs, ... }: ''
      tmp=$(mktemp -d)
      trap "rm -rf $tmp" EXIT
      ${pkgs.openssh}/bin/ssh-keygen -q \
        -t rsa-sha2-512 \
        -b 4096 \
        -C "agenix" \
        -N "" \
        -f "$tmp/key"
      cat "$tmp/key"
    '';
  };

  flake.modules.homeManager.core = { osConfig, ... }: {
    age.generators.ssh-rsa-4096 = osConfig.age.generators.ssh-rsa-4096;
  };
}
