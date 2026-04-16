default:
    @just --list

# ── Dev ───────────────────────────────────────────────────────────────────────

# Format the repo
[group('dev')]
fmt:
    treefmt

# Run flake checks
[group('dev')]
check:
    nix flake check

# Update all flake inputs
[group('dev')]
update input="":
    nix flake update {{ input }}
