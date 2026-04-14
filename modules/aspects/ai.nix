{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.ai.imports = with nixos; [
      llm-agents
    ];

    homeManager.ai.imports = with homeManager; [
      # agents
      claudecode
      forgecode
      opencode

      # chat
      aichat

      # workflow
      ai-management
      ai-review
      ai-utilities
    ];
  };
}
