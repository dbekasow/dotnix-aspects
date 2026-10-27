#!/usr/bin/env bash
set -euo pipefail

message='DMS and Noctalia cannot both be selected for the same Home Manager target.'
if output=$(NIRI_DMS_CONFLICT_ONLY=1 nix eval --impure --show-trace --raw --file tests/niri-dms.nix 2>&1); then
  printf 'Expected conflicting shell activation to fail.\n' >&2
  exit 1
fi

if ! grep -Fq "$message" <<<"$output"; then
  printf '%s\n' "$output" >&2
  printf 'Expected diagnostic was absent: %s\n' "$message" >&2
  exit 1
fi

printf 'DMS/Noctalia conflict diagnostic verified.\n'
