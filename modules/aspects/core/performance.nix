{
  # Kernel tuning for a laptop with plenty of RAM and swap on Btrfs+LUKS.
  # Kept separate from boot.nix since this is purely about runtime behavior,
  # not booting.
  flake.modules.nixos.performance = {
    boot.kernel.sysctl = {
      # The swapfile sits behind LUKS on Btrfs — touch it as late as
      # possible.
      "vm.swappiness" = 10;

      # Hold on to the dentry/inode cache longer (plenty of RAM available).
      "vm.vfs_cache_pressure" = 50;

      # Start writeback earlier and in smaller chunks, otherwise Btrfs+LUKS
      # visibly stalls during large copy operations.
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;

      # The default of ~65k is too low for Wine/Proton/Electron.
      "vm.max_map_count" = 2147483642;
    };

    # Compressed RAM swap ahead of the swapfile. The swapfile stays around
    # for hibernation (boot.resumeDevice) but is barely touched otherwise.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25;
      priority = 100;
    };

    # nixos-hardware's common/pc/laptop/ssd usually sets this already —
    # explicit here so it doesn't depend on the host config.
    services.fstrim.enable = true;
  };
}
