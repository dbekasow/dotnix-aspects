# Btrfs root rollback recovery

Break-glass guidance only. Do not run these commands on a live system as part of
library evaluation. Use a rescue environment and identify the host's actual
Btrfs device first. For encrypted hosts, decrypt using that host's documented
LUKS device and credentials; this guide does not prescribe a device path.

## Inspect without changing subvolumes

Back up important data before any recovery operation. Identify the Btrfs device
and any mapper from the rescue environment's device inventory; do not guess.
Mount the Btrfs top level read-only without tree-log replay, substituting the
verified device and a rescue mount directory. Btrfs can replay its log and write
metadata even on a `ro` mount; `nologreplay` prevents that during inspection:

```sh
mount -t btrfs -o ro,nologreplay,subvolid=5 VERIFIED_BTRFS_DEVICE RESCUE_MOUNTPOINT
btrfs subvolume list RESCUE_MOUNTPOINT
btrfs subvolume show RESCUE_MOUNTPOINT/@root
btrfs subvolume show RESCUE_MOUNTPOINT/@root-blank
btrfs property get -ts RESCUE_MOUNTPOINT/@root-blank ro
```

Confirm the baseline is the intended snapshot and reports `ro=true`. Unmount when
inspection is complete:

```sh
umount RESCUE_MOUNTPOINT
```

Do not mount an unverified device read-write or run deletion commands during
inspection.

## Recovery decision

- If `@root-blank` is missing, stop. Do not delete or replace `@root`; boot is
  expected to fail closed because no known-good baseline is available.
- If rollback failed after deletion began, treat any existing `@root` as
  potentially partial. Do not delete, overwrite, or automatically replace it.
  Preserve it and all other data for assessment.
- Back up the Btrfs filesystem or otherwise secure required data before
  attempting recovery. Preserve sibling subvolumes `@persist`, `@nix`, `@log`,
  and `@swap`; rollback targets only `@root`.
- Restore only when `@root` is absent, `@root-blank` is confirmed to be the
  intended known-good read-only snapshot, backup is complete, and an authorized
  operator has approved recovery. Never use wildcard deletion or broad cleanup.

After those conditions are met, with the verified device mounted read-write at
its Btrfs top level, the authorized operator may create `@root` from the known-
good snapshot only if `@root` is absent:

```sh
btrfs subvolume snapshot RESCUE_MOUNTPOINT/@root-blank RESCUE_MOUNTPOINT/@root
```

Do not run this command if `@root` already exists. Remount or separately mount
the resulting `@root` as the host normally does, then verify that the restored
root is writable before attempting boot. Do not change sibling subvolumes.

## Limits and test evidence

Recursive deletion of `@root` is non-atomic: a failure after deletion begins can
leave `@root` absent or incomplete. The initrd rollback unit checks for both
subvolumes before deletion and fails closed, but it cannot make deletion
transactional. `RemainAfterExit` keeps a successful oneshot active so the
`sysroot.mount` dependency does not replay rollback during initrd cleanup. An
explicit stop followed by restart can run it again; do not manually restart it
as a recovery technique.

The rollback regression uses disposable Btrfs VM storage with a directly
labeled, unencrypted disk. It tests nested and space-containing subvolumes,
missing baseline and pre-delete failure behavior, sibling preservation, and
prevention of a second rollback execution. It is not a real encrypted-host,
hibernate, dock, or live-host test. See [initrd resume ordering](resume-order.md)
and [the disposable rollback VM](../tests/btrfs-rollback/vm.nix) for the scoped
checks.
