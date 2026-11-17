{
  imports = [ ./parts/devtools.nix ];

  # Base declares agenix-rekey for runtime configuration. Reuse the
  # Consumer's tooling inputs only when it also opts into DevTools.
  flake-file.inputs.agenix-rekey.inputs = {
    devshell.follows = "devshell";
    pre-commit-hooks.follows = "git-hooks";
    treefmt-nix.follows = "treefmt";
  };
}
