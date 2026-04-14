{ inputs, ... }: {
  flake.modules.nixos.llm-agents = {
    nixpkgs.overlays = [ inputs.llm-agents.overlays.default ];
    nix.settings = {
      substituters = [ "https://cache.numtide.com" ];
      trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };
  };
}
