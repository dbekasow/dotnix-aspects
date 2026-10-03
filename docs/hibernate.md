# Hibernate prerequisites

The library's Disko layout creates a 64G Btrfs swapfile at `/swap/swapfile` in
`@swap`, mounted at `/swap`. Disko uses `btrfs filesystem mkswapfile` to
prepare a NOCOW, preallocated swapfile. Hibernate still requires the actual
swapfile offset and backing resume device; neither can be inferred from the
layout alone.

After provisioning the host, verify the swapfile exists and is active, then
obtain its offset:

```sh
findmnt /swap
swapon --show
btrfs inspect-internal map-swapfile -r /swap/swapfile
```

Confirm `/swap` is the expected Btrfs subvolume and the swapfile is active.
`@swap` lists only `noatime`, but Btrfs compression may be filesystem-wide and
first-mount dependent; do not infer the effective options from that list. The
map command validates the provisioned swapfile mapping and reports its
resume offset. Use that reported offset as `resume_offset=` in that host's kernel parameters.
It is specific to the provisioned swapfile and page size; do not copy an offset
from another machine or invent one at evaluation time. The offset is distinct
from `boot.resumeDevice`, which names the block device containing the swapfile.
The power aspect defaults that device to `/dev/mapper/cryptroot` for its
encrypted layout. Plain or custom layouts must set `boot.resumeDevice` to their
actual backing device.

The performance aspect also enables zram, a higher-priority compressed RAM
swap device. Zram is volatile and cannot serve as a persistent Hibernate
resume source. These are prerequisites only: no host-specific offset or
resume-device override is configured automatically. Do not activate or test
Hibernate against a live host as part of evaluation.
