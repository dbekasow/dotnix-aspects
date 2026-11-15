# Integrated reference consumer verification

Ticket 06 evidence, 2026-11-15. Predecessor tickets 01–05 were integrated at
`fc10310af98ca29f0140a5917dab5c5bfc1bf738`. Detailed logs are in
`/tmp/epc-06-evidence/`; the commands and outcomes below do not depend on
those logs being retained.

## Actual published template

On x86_64-linux with Nix 2.34.9, the following commands created an unchanged
copy and its **initial disposable** lock. The sole input override was `dotnix`
to this worktree; `diff` excludes only that disposable lock. The copy retains
`hardware.nix`'s actual `nixos-hardware.nixosModules.dell-precision-5570`
import and the template's host/home compositions, identities, state versions,
and selections. No credentials or other template changes were added.

```console
cd /home/denis/projects/dotnix-aspects-worktrees/06
nix flake new /tmp/epc-06-evidence/consumer-acceptance --template 'path:/home/denis/projects/dotnix-aspects-worktrees/06#default' --accept-flake-config
nix flake lock /tmp/epc-06-evidence/consumer-acceptance --override-input dotnix path:/home/denis/projects/dotnix-aspects-worktrees/06
diff -ru --exclude=flake.lock /home/denis/projects/dotnix-aspects-worktrees/06/modules/templates/dotnix /tmp/epc-06-evidence/consumer-acceptance
nix eval --raw --no-write-lock-file /tmp/epc-06-evidence/consumer-acceptance#nixosConfigurations.myHost.config.system.build.toplevel.drvPath --max-jobs 1 --cores 4
timeout --signal=TERM --kill-after=60s 3600s nix build --no-link --print-out-paths --no-write-lock-file --max-jobs 2 --cores 4 -L /tmp/epc-06-evidence/consumer-acceptance#nixosConfigurations.myHost.config.system.build.toplevel
nix path-info -rS /nix/store/vkhsw299v91y1537y7c740kqa2hzgxcm-nixos-system-myHost-26.11.20261112.2074cc6
```

Each exited 0. The derivation evaluation returned
`/nix/store/1w5bad5zs2baiwgvqnk8pk4q61lhrjw4-nixos-system-myHost-26.11.20261112.2074cc6.drv`.
The complete build returned
`/nix/store/vkhsw299v91y1537y7c740kqa2hzgxcm-nixos-system-myHost-26.11.20261112.2074cc6`;
`nix path-info -rS` successfully traversed 2,176 closure paths. The prior
unchanged template copy also built successfully in about 10½ minutes and
populated the store; the final copy reused those dependencies and built six
remaining derivations. Both had a 3,600-second budget, two jobs, four cores
per job, and completed with exit 0. Neither build activated the system.
GitHub's unauthenticated API returned 403 while the initial lock was created;
Nix used cached metadata and completed the lock (exit 0). No repository input,
pin, or lockfile was changed.

The following query against the same actual copied system checks emitted
settings and effective home packages, not only selector declarations:

```console
nix eval --json --no-write-lock-file /tmp/epc-06-evidence/consumer-acceptance#nixosConfigurations.myHost.config --apply '
  c: let
    h = c.home-manager.users.myuser;
    b = h.programs.niri.settings.binds;
    names = map (p: p.pname or (builtins.parseDrvName p.name).name) h.home.packages;
  in {
    applications = h.programs.ghostty.enable && h.programs.firefox.enable && h.programs.thunderbird.enable && builtins.all (p: builtins.elem p h.home.packages) [ h.programs.ghostty.package h.programs.firefox.finalPackage h.programs.thunderbird.package ];
    launchKeys = b."Mod+T".action.spawn == [ "ghostty" ] && b."Mod+B".action.spawn == [ "firefox" ] && b."Mod+O".action.spawn == [ "thunderbird" ] && !(builtins.hasAttr "Mod+E" b);
    noRemainder = builtins.all (n: !(builtins.elem n names)) [ "alacritty" "anki" "handy" "onlyoffice" ];
    storage = c.boot.loader.systemd-boot.enable && c.disko.devices.disk.main.device == "/dev/nvme0n1" && c.disko.devices.disk.main.content.partitions.root.content.type == "luks" && c.disko.devices.disk.main.content.partitions.root.content.enrollFido2 && c.disko.devices.disk.main.content.partitions.root.content.content.type == "btrfs" && c.fileSystems."/".fsType == "btrfs" && c.environment.persistence ? "/persist";
    optionalHostFeaturesAbsent = !(c.boot.initrd.systemd.services ? rollback-root) && !(c.boot.kernel.sysctl ? "vm.swappiness") && !(c.boot.kernel.sysctl ? "vm.vfs_cache_pressure") && !(c.boot.kernel.sysctl ? "vm.dirty_background_ratio") && !(c.boot.kernel.sysctl ? "vm.dirty_ratio") && c.boot.kernel.sysctl."vm.max_map_count" != 2147483642 && !c.zramSwap.enable && c.location.provider == "manual" && !c.services.pcscd.enable && !(builtins.any (p: (p.pname or "") == "yubikey-personalization") c.services.udev.packages);
  }' > /tmp/epc-06-evidence/20-durable-template-observe.json
jq -e '[.[]] | all' /tmp/epc-06-evidence/20-durable-template-observe.json
```

Both commands exited 0 and all five observations were true. A first attempt
used `jq -e 'all(.[])'` and exited 5 due to the query's shape; the corrected
command above exited 0. GeoClue's service can independently be enabled by
another selected component; the observation checks the provider policy of
`host.geolocation` rather than asserting that the service is disabled.

## Integrated consumer checks

All commands below exited 0 on the combined slices, with the regular check
building or reusing its check derivations:

```console
nix fmt
nix flake check --no-write-lock-file --accept-flake-config --max-jobs 1 --cores 2
nix eval --impure --raw --file /home/denis/projects/dotnix-aspects-worktrees/06/tests/headless-composition.nix --apply 'fixture: fixture { }'
nix build --no-link --no-write-lock-file /home/denis/projects/dotnix-aspects-worktrees/06#checks.x86_64-linux.consumer-headless-security
nix eval --impure --json --file /home/denis/projects/dotnix-aspects-worktrees/06/tests/niri-dms.nix --apply 'fixture: fixture { }'
nix eval --impure --json --file /home/denis/projects/dotnix-aspects-worktrees/06/tests/terminal-composition.nix --apply 'fixture: fixture { }'
nix eval --impure --json --file /home/denis/projects/dotnix-aspects-worktrees/06/tests/review-access.nix --apply 'fixture: fixture { }'
bash /home/denis/projects/dotnix-aspects-worktrees/06/tests/niri-dms-conflict.sh
```

The Niri fixture returned 52 true assertions, preserving all 48 named baseline
assertions; the two-user terminal and review fixtures returned 9 and 4 true
assertions respectively. The terminal fixture now explicitly checks the
previously uncovered combined `home.terminal` + `home.development` Hunk
popup on the generated Tmux configuration; the existing review fixture had
separately checked direct Hunk + Tmux and development alone. It was already
green on the integrated implementation, without fault injection. Existing
fixtures cover the workstation/control and native-power overrides, server and
family-home independence, per-home Hunk isolation, both popup renderers, and
explicit Workmux behavior. Formatting, generated-flake and pre-commit checks
remain in the regular gate. Non-host incompatible systems were omitted by Nix.

## Limits

This verifies configuration evaluation and a completed system closure, not
activation, real hardware behavior, interactive multiplexer use, or runtime
storage safety. `/dev/kvm` was absent; no device permissions were changed and
no Btrfs VM runtime was attempted. The earlier Btrfs VM derivation evaluated,
but its 300-second build timed out before runtime (exit 124); that preexisting
runtime gap remains open. No activation, live consumer migration, host disk
operation, credential creation, or loading redesign was performed.
