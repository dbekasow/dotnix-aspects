# Impermanence contribution for llm-agents — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    # pi keeps sessions and chat history under its agent home, ~/.pi/agent
    # by default (pi docs v0.87.1 — a dot directory, not XDG data/cache).
    home.persistence."/persist".directories = [ ".pi" ];
  };
}
