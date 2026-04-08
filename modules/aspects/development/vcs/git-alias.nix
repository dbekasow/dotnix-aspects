{
  flake.modules.homeManager.git-alias = {
    programs.git.settings.alias = {
      # Status shortcuts
      s = "status --short --branch";
      st = "status";

      # Log aliases
      l = "log --oneline --graph --decorate";
      ll = "log --graph --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %C(green)(%cr) %C(bold blue)<%an>%Creset'";
      last = "log -1 HEAD --stat";

      # Branch aliases
      b = "branch";
      ba = "branch --all";
      bd = "branch --delete";
      bD = "branch --delete --force";

      # Checkout aliases
      co = "checkout";
      cob = "checkout -b";

      # Diff aliases
      d = "diff";
      ds = "diff --staged";
      dw = "diff --word-diff";

      # Stash aliases
      sl = "stash list";
      ss = "stash save";
      sp = "stash pop";

      # Commit aliases
      c = "commit";
      ca = "commit --amend";
      can = "commit --amend --no-edit";

      # Remote aliases
      f = "fetch";
      fa = "fetch --all";
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";

      # Undo aliases
      unstage = "reset HEAD --";
      undo = "reset --soft HEAD^";
      amend = "commit --amend --no-edit";

      # Utility aliases
      root = "rev-parse --show-toplevel";
      contributors = "shortlog --summary --numbered --email";
    };
  };
}
