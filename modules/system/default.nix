{
  imports = [
    ../consumer.nix
    ../base/features/boot.nix
    ../base/features/journald.nix
    ../base/features/security.nix
    ../base/profiles/boot-baseline.nix
    ../base/profiles/server.nix
    ./features/ssh.nix
    ./features/users.nix
  ];
}
