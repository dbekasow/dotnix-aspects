#!/usr/bin/env bash
set -euo pipefail

check_conflict() {
	local mode=$1 message=$2 output
	if output=$(NIRI_DMS_CONFLICT_ONLY="$mode" nix eval --impure --no-write-lock-file --show-trace --raw --file tests/niri-dms.nix --apply 'fixture: fixture { }' 2>&1); then
		printf 'Expected conflicting shell activation to fail.\n' >&2
		exit 1
	fi

	if ! grep -Fq "$message" <<<"$output"; then
		printf '%s\n' "$output" >&2
		printf 'Expected diagnostic was absent: %s\n' "$message" >&2
		exit 1
	fi
}

check_conflict 1 'DMS and Noctalia cannot both be selected for the same Home Manager target.'
check_conflict host 'DMS and Noctalia cannot both be selected on the same host.'
printf 'DMS/Noctalia conflict diagnostics verified.\n'
