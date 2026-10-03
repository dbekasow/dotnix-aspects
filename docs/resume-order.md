# Initrd resume and rollback ordering evidence

## Result

The baseline NixOS initrd-systemd VM let the non-destructive rollback probe start before `systemd-hibernate-resume.service` completed. In the captured run, rollback probe started at 1.199 s; the generated resume service attempted its configured target at 1.517 s. No direct dependency existed between them. This establishes an ordering gap, not proof of a destructive race or of resume being active concurrently.

Adding both `Requires=systemd-hibernate-resume.service` and `After=systemd-hibernate-resume.service` made the probe run only after service completion. The library now adds those edges only when `boot.resumeDevice` is configured. Without that option (cold/noresume configuration), the library adds no resume dependency. The rollback unit is also `requiredBy = [ "sysroot.mount" ]` and ordered before it, so a required rollback failure blocks the root mount. The disposable rollback VM verifies missing-baseline and pre-delete failures block `sysroot.mount`; the resume-order test below does not inject a failing resume executable, so it does not independently verify propagation of resume-service failure to the root mount. A caller that supplies `resume=` only through arbitrary kernel parameters instead of `boot.resumeDevice` is outside this condition and must add equivalent ordering.

The test uses NixOS `runNixOSTest` and disposable QEMU guests. It exercises the real initrd systemd resume generator and service against a deliberately invalid VM resume target, then delays service completion with a synthetic eight-second stub. The rollback action only writes a marker. It does not import or run the library's Btrfs rollback script, access host storage, hibernate, or format disks. Synthetic delay demonstrates systemd ordering; it is not evidence of real hibernation/resume behavior.

## Reproduction

From the repository root, evaluate the disposable VM against this checkout and its current lock:

```sh
nix build --impure --no-link --no-write-lock-file --expr 'let root = builtins.getFlake (toString ./.); pkgs = import root.inputs.nixpkgs { system = "x86_64-linux"; }; in import ./tests/resume-order/vm.nix { inherit pkgs; library = root; }' --print-build-logs
```

The initial run on the disposable worktree used systemd 261.2. A rerun against the current main-worktree lock used systemd 261.3. Both runs passed; the command above reproduces the current-checkout run. Assertions passed:

- Baseline: `not-started`; rollback probe ran before resume service.
- Ordered: `completed`; resume service finished before rollback probe.
- Cold without configured `boot.resumeDevice`: `no-resume`; no resume job was active and rollback probe proceeded. The test does not pass kernel `noresume` and does not verify that parameter.

The ordered node imports the library's exported `nixosModules.impermanence` aspect and force-replaces `rollback-root.script` with a marker-only probe. The baseline remains independent of the library aspect. No destructive Btrfs rollback script runs in either node. This resume-order VM does not inject a failing service. A separate disposable rollback VM confirms that a failed rollback blocks `sysroot.mount`, but it does not simulate resume-service failure. Synthetic delay demonstrates systemd ordering, not actual hibernation or resume behavior.
