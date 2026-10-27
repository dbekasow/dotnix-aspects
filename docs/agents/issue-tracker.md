# Issue tracker: Local Markdown

Specs and issues live in this repository under `.scratch/`.
Use filesystem operations, not remote tracker tools.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`.
- Canonical spec: `.scratch/<feature-slug>/spec.md`.
- One implementation ticket per file:
  `.scratch/<feature-slug>/issues/<NN>-<slug>.md`.
- Number tickets in dependency order, starting at `01`.
- Record triage state near the top as `Status: <role>`;
  use `triage-labels.md` for role names.
- Record dependencies as `Blocked by:` with relative ticket links.
- Append discussion under `## Comments`.

## Skill operations

- Publish a spec: create or update its canonical spec file.
- Publish tickets: create one file per approved ticket.
- Fetch an issue: read its file and appended comments.
- Preserve existing discussion when updating an issue.
- Readiness status does not authorize implementation;
  respect the user's separate execution approval.

## Wayfinding operations

- Map: `.scratch/<effort>/map.md`.
- Decision tickets: `.scratch/<effort>/issues/NN-<slug>.md`.
- Record `Type: research|prototype|grilling|task`.
- Claim with `Status: claimed` before work.
- Resolve by appending `## Answer` and setting `Status: resolved`.
- A decision ticket is unblocked when every blocker is resolved.
- The frontier contains unclaimed, unblocked decision tickets.
- On resolution, add a named link and gist to the map's decisions.
