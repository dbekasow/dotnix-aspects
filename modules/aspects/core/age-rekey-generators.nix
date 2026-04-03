{
  flake.modules.nixos.core = { lib, ... }: {
    age.generators.ssh-rsa-4096 = { pkgs, file, ... }: ''
      keyfile=$(mktemp)
      trap 'rm -f "$keyfile" "$keyfile.pub"' EXIT
      rm "$keyfile"
      ${pkgs.openssh}/bin/ssh-keygen \
        -t rsa-sha2-512 \
        -b 4096 \
        -C "agenix" \
        -N "" \
        -f "$keyfile" 2>/dev/null
      cp "$keyfile.pub" ${lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")}
      cat "$keyfile"
    '';
  };

  flake.modules.homeManager.core = { osConfig, ... }: {
    age.generators = osConfig.age.generators;
  };
}
