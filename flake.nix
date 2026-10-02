{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";

    # agenix-rekey's own tool inputs are frozen 2024 upstream lock pins; its
    # dev chain is never entered from the modules we import. Collapse them
    # onto our inputs so one dev toolchain (and fewer lock nodes) remains.
    agenix-rekey.inputs.devshell.follows = "devshell";
    agenix-rekey.inputs.flake-parts.follows = "flake-parts";
    agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";
    agenix-rekey.inputs.pre-commit-hooks.follows = "git-hooks";
    agenix-rekey.inputs.treefmt-nix.follows = "treefmt";
    agenix-rekey.url = "github:oddlama/agenix-rekey";

    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    direnv-instant.url = "github:Mic92/direnv-instant";
    direnv-instant.inputs.nixpkgs.follows = "nixpkgs";

    dms.inputs.nixpkgs.follows = "nixpkgs";
    dms.url = "github:AvengeMedia/DankMaterialShell";

    dms-plugins.inputs.nixpkgs.follows = "nixpkgs";
    dms-plugins.url = "github:AvengeMedia/dms-plugin-registry";

    # One dank-qml-common node for both consumers: shell and greeter share
    # the QML base; two independently rolling nodes (shell 2026-09-28 vs
    # greeter 2026-09-22 at last lock) risk a greeter/shell mismatch.
    dank-greeter.inputs.dank-qml-common.follows = "dms/dank-qml-common";
    dank-greeter.inputs.nixpkgs.follows = "nixpkgs";
    dank-greeter.url = "github:AvengeMedia/dank-greeter";

    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks.url = "github:cachix/git-hooks.nix";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";

    impermanence.inputs.home-manager.follows = "home-manager";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";

    import-tree.url = "github:vic/import-tree";

    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Fork of sodiboo/niri-flake: switched in 417528f ("fix: resolve nix check
    # warnings") with no recorded reason; currently synced with upstream —
    # revisit switching back to sodiboo/niri-flake.
    niri.inputs.nixpkgs.follows = "nixpkgs";
    # Guard: only niri-unstable is referenced anywhere (compositor/niri.nix).
    # Folding nixpkgs-stable onto our unstable pin intentionally breaks the
    # unused niri-stable lane and its weekly lock churn.
    niri.inputs.nixpkgs-stable.follows = "nixpkgs";
    niri.url = "github:epireyn/niri-flake";

    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.nur.follows = "nur";
    stylix.url = "github:nix-community/stylix";

    treefmt.inputs.nixpkgs.follows = "nixpkgs";
    treefmt.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
}
