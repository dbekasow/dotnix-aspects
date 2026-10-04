{ inputs, ... }: {
  flake.modules.nixos.llm-agents = {
    nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];
    nix.settings = {
      substituters = [ "https://cache.numtide.com" ];
      trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };
  };

  # Impermanence contribution for llm-agents.
  flake.modules.homeManager.impermanence = {
    # pi keeps sessions and chat history under its agent home, ~/.pi/agent
    # by default (pi docs v0.87.1 — a dot directory, not XDG data/cache).
    home.persistence."/persist".directories = [ ".pi" ];
  };
}
