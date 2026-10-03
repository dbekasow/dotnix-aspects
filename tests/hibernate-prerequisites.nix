let
  source = builtins.getFlake (toString ../.);
  inherit (source.inputs) nixpkgs;
  inherit (nixpkgs) lib;
  system = "x86_64-linux";

  evaluate = encrypt: resumeDevice: kernelParams:
    (lib.nixosSystem {
      inherit system;
      modules = [
        source.modules.nixos.disko
        { disko.devices.disk.main.device = "/dev/vda"; }
        source.modules.nixos.power
        source.modules.nixos.performance
        {
          dotnix.disk.encrypt = encrypt;
          boot.resumeDevice = resumeDevice;
          boot.kernelParams = kernelParams;
          system.stateVersion = "25.11";
        }
      ];
    }).config;

  encrypted = evaluate true "/dev/host-resume" [ "host-kernel-parameter=encrypted" ];
  plain = evaluate false "/dev/disk/by-label/nixos" [ "host-kernel-parameter=plain" ];

  rootContent = config: config.disko.devices.disk.main.content.partitions.root.content;
  btrfsContent = content: if content.type == "luks" then content.content else content;
  swap = config: (btrfsContent (rootContent config)).subvolumes."@swap";
in
assert (rootContent encrypted).type == "luks";
assert (btrfsContent (rootContent encrypted)).type == "btrfs";
assert (rootContent plain).type == "btrfs";
assert (swap encrypted).mountpoint == "/swap";
assert (swap encrypted).mountOptions == [ "noatime" ];
assert (swap encrypted).swap.swapfile.size == "64G";
assert (swap plain).mountpoint == "/swap";
assert (swap plain).mountOptions == [ "noatime" ];
assert (swap plain).swap.swapfile.size == "64G";
assert encrypted.boot.resumeDevice == "/dev/host-resume";
assert plain.boot.resumeDevice == "/dev/disk/by-label/nixos";
assert builtins.elem "host-kernel-parameter=encrypted" encrypted.boot.kernelParams;
assert builtins.elem "host-kernel-parameter=plain" plain.boot.kernelParams;
assert !(builtins.elem "mem_sleep_default=deep" encrypted.boot.kernelParams);
assert !(builtins.elem "mem_sleep_default=deep" plain.boot.kernelParams);
assert encrypted.zramSwap.enable && encrypted.zramSwap.priority > 0;
assert plain.zramSwap.enable && plain.zramSwap.priority > 0;
"hibernate fixture passed"
