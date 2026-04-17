{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
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
