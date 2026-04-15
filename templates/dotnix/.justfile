default:
    @just --list

# ── Dev ───────────────────────────────────────────────────────────────────────

# Format the repo
[group('dev')]
fmt:
    nix flake fmt

# Run flake checks
[group('dev')]
check:
    nix flake check

# Update all flake inputs
[group('dev')]
update input="":
    nix flake update {{ input }}

# Show whats changed
[group('dev')]
diff host:
    nh os build -H {{ host }} --dry

# ── Deploy ────────────────────────────────────────────────────────────────────

# Rebuild and switch
[group('deploy')]
switch host:
    nh os switch -H {{ host }}

# Rebuild and test
[group('deploy')]
test host:
    nh os test -H {{ host }}

# Build without activating
[group('deploy')]
build host:
    nh os build -H {{ host }}

# ── Secrets ───────────────────────────────────────────────────────────────────

# Rekey all secrets
[group('secrets')]
rekey:
    nix run .#rekey

# Edit a secret
[group('secrets')]
edit secret:
    agenix -e {{ secret }}

# ── Maintenance ───────────────────────────────────────────────────────────────

# Collect garbage
[group('maintenance')]
gc keep="3" since="7d":
    nh clean all --keep {{ keep }} --keep-since {{ since }}

# Show current generation tree
[group('maintenance')]
tree host:
    nix-tree .#nixosConfigurations.{{ host }}.config.system.build.toplevel
