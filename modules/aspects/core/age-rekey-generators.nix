{
  flake.modules.nixos.age-rekey-generators = {
    age.generators.ssh-rsa-4096 = { pkgs, ... }: ''
      tmp=$(mktemp -d)
      trap "rm -rf $tmp" EXIT
      ${pkgs.openssh}/bin/ssh-keygen -q \
        -t rsa-sha2-512 \
        -b 4096 \
        -C "agenix" \
        -N "" \
        -f "$tmp/key" 2>/dev/null
      cat "$tmp/key"
    '';
  };

  flake.modules.homeManager.age-rekey-generators = { osConfig, ... }: {
    age.generators.ssh-rsa-4096 = osConfig.age.generators.ssh-rsa-4096;
  };
}
