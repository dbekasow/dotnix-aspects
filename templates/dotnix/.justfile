default:
    @just --list

# ── Dev ───────────────────────────────────────────────────────────────────────

[doc('Format the repo')]
[group('dev')]
fmt:
    nix flake fmt

[doc('Run flake checks')]
[group('dev')]
check:
    nix flake check

[doc('Update all flake inputs')]
[group('dev')]
update input="":
    nix flake update {{ input }}

[doc('Show whats changed')]
[group('dev')]
diff host:
    nh os build -H {{ host }} --dry

# ── Deploy ────────────────────────────────────────────────────────────────────

[doc('Rebuild and switch')]
[group('deploy')]
switch host:
    nh os switch -H {{ host }}

[doc('Rebuild and test')]
[group('deploy')]
test host:
    nh os test -H {{ host }}

[doc('Build without activating')]
[group('deploy')]
build host:
    nh os build -H {{ host }}

[group('deploy')]
iso host:
    nix build .#{{ host }}-iso

# ── Secrets ───────────────────────────────────────────────────────────────────

[doc('Rekey all secrets')]
[group('secrets')]
rekey:
    nix run .#rekey

[doc('Edit a secret')]
[group('secrets')]
edit secret:
    agenix -e {{ secret }}

# ── Maintenance ───────────────────────────────────────────────────────────────

[doc('Collect garbage')]
[group('maintenance')]
gc keep="3" since="7d":
    nh clean all --keep {{ keep }} --keep-since {{ since }}

[doc('Show current generation tree')]
[group('maintenance')]
tree host:
    nix-tree .#nixosConfigurations.{{ host }}.config.system.build.toplevel

# ── Bootstrap ─────────────────────────────────────────────────────────────────

bootstrapDir := "/tmp/bootstrap"
hostDir := "modules/host"

[doc('Generate ssh host keypair')]
[group('bootstrap')]
hostkey host:
    @mkdir -p {{ bootstrapDir }}/{{ host }}
    ssh-keygen -t ed25519 -N "" -f {{ bootstrapDir }}/{{ host }}/ssh_host_ed25519_key

[doc('Copy public hostkey to secrets')]
[group('bootstrap')]
hostkey-install host:
    install -m 644 {{ bootstrapDir }}/{{ host }}/ssh_host_ed25519_key.pub {{ hostDir }}/{{ host }}/secrets

[doc('Bootstrap a new host')]
[group('bootstrap')]
bootstrap host disk *args:
    sudo nix run github:nix-community/disko/latest#disko-install -- {{ args }} \
    --write-efi-boot-entries \
    --flake "path:.#{{ host }}" \
    --disk main {{ disk }} \
    --extra-files {{ bootstrapDir }}/{{ host }} /persist/etc/ssh
