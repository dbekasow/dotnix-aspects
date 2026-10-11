# Proposal

## Why

The native Den migration is committed but is not merge-ready: review reproduced broken consumer evaluation, incorrect consumer-resource binding, lost configuration defaults, and unusable fixtures. Preserve the review and a prioritized repair plan so the next session can restore the intended behavior without repeating the migration or its investigation.

## What Changes

- Restore consumer-owned secret/resource resolution without reintroducing export wrappers or custom `dotnix` options.
- Repair module argument scope, remaining identity-option consumers, Tmux defaults/menu integration, hostnames, and targeted PipeWire persistence.
- Restore supported native development-tool integration and migrate existing templates/manual tests off removed APIs.
- Establish portable source/lock handling and verify generated flakes, host evaluation, and existing checks.
- Keep the full review findings, Den assessment matrix, LOC measurements, and explicit verification limits in `review.md`.
- Address post-review shell-routing, Herdr and agent-tool integration defects through native Den composition; share requested popup launcher metadata without introducing a second profile system.

## Capabilities

### New Capabilities

None. This is review remediation of the already intended migration contract, not a new feature proposal. `skip_specs: true` avoids inventing new requirements merely to persist findings.

### Modified Capabilities

None. No published main specs exist; this change records repairs and validation for intended behavior rather than introducing additional behavior or compatibility APIs.

## Impact

- Planning home: `/home/denis/projects/dotnix-aspects/openspec/changes/repair-den-migration-review`.
- Library target: `/home/denis/projects/dotnix-aspects`, branch `feat/den-migration`, reviewed commit `359b3b3226dc9fac856ed2e4c2c342ef0cee0336`.
- Consumer target: `/home/denis/projects/dotnix`, branch `feat/den-migration`, reviewed commit `831756fe32505fa6471fc14f2675861f81bf5a3a`.
- Both repositories must be considered when implementing. This repo-local OpenSpec change does not itself expand apply tooling's allowed edit roots to the consumer: retain explicit user authorization and resolve cross-repository scope before applying.
- Den remains pinned to `7594405b45e0ce2d5a418fe104a26e17f6b1dd8f`; unrelated input updates, live activation, and pushes are out of scope.
- The existing `clarify-aspect-boundaries-and-harden-workstation` change is not modified or archived.
- Explicit later choices retain the local-only consumer source (portability task remains open), keep Workmux separate from Herdr, select graphical shells per user, and introduce a focused launcher-data Quirk. Separate boundary hardware/identity tests are excluded without claiming them passed.
