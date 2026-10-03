let
  source = builtins.getFlake (toString ../.);
  inherit (source.inputs) nixpkgs;
  inherit (nixpkgs) lib;
  system = "x86_64-linux";

  evaluate = encrypted: (lib.nixosSystem {
    inherit system;
    modules = [
      source.inputs.agenix.nixosModules.default
      source.inputs.home-manager.nixosModules.home-manager
      source.nixosModules.impermanence
      (_: {
        boot = {
          initrd.systemd.enable = true;
          resumeDevice = lib.mkIf encrypted "/dev/mapper/cryptroot";
          initrd.luks.devices.cryptroot = lib.mkIf encrypted {
            device = "/dev/disk/by-label/nixos";
          };
        };
        system.stateVersion = "25.11";
      })
    ];
  }).config.boot.initrd.systemd.services.rollback-root;

  encrypted = evaluate true;
  plain = evaluate false;
  deviceUnit = "dev-disk-by\\x2dlabel-nixos.device";
  resumeUnit = "systemd-hibernate-resume.service";
  cryptrootUnit = "systemd-cryptsetup@cryptroot.service";
  has = value: list: builtins.elem value list;
in
assert has deviceUnit encrypted.requires;
assert has deviceUnit encrypted.after;
assert has cryptrootUnit encrypted.requires;
assert has cryptrootUnit encrypted.after;
assert has resumeUnit encrypted.requires;
assert has resumeUnit encrypted.after;
assert has deviceUnit plain.requires;
assert has deviceUnit plain.after;
assert !(has cryptrootUnit plain.requires);
assert !(has cryptrootUnit plain.after);
assert !(has resumeUnit plain.requires);
assert !(has resumeUnit plain.after);
assert has "sysroot.mount" encrypted.requiredBy;
assert has "sysroot.mount" plain.requiredBy;
assert has "sysroot.mount" encrypted.before;
assert has "sysroot.mount" plain.before;
assert encrypted.unitConfig.DefaultDependencies == "no";
assert plain.unitConfig.DefaultDependencies == "no";
assert lib.hasInfix "btrfs subvolume delete --recursive" encrypted.script;
assert lib.hasInfix "btrfs subvolume show" encrypted.script;
assert lib.hasInfix ''btrfs subvolume snapshot "$mountpoint/@root-blank" "$mountpoint/@root"'' encrypted.script;
"rollback initrd fixture passed"
