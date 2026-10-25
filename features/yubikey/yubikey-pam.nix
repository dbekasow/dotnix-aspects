{
  # u2f login needs host key material — the whole aspect follows that gate.
  dotnix.yubikey-pam = { inputs, ... }: {
    nixos = { host, config, lib, pkgs, ... }:
      lib.mkIf
        (lib.pathExists "${inputs.self}/modules/hosts/${host.name}/secrets/ssh_host_ed25519_key.pub")
        {
          age.secrets.u2f.generator.script = _: ''
            printf '# nix shell nixpkgs#pam_u2f -c pamu2fcfg -u $(whoami) -o pam://$(hostname) -i pam://$(hostname)'
          '';

          # pam.u2f.enable is the global switch: it installs pam_u2f into every
          # PAM service that doesn't opt out (login, sudo, sshd, polkit) — that
          # fleet-wide security floor is intended, so no per-service enables.
          security.pam.u2f = {
            enable = true;

            settings = {
              authfile = config.age.secrets.u2f.path;
              interactive = true;
              cue = true;
              nouserok = true;
            };
          };

          programs.yubikey-manager.enable = true;
          environment.systemPackages = with pkgs; [ yubioath-flutter yubikey-manager ];
        };
  };
}
