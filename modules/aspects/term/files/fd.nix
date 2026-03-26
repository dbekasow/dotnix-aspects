{
  flake.modules.homeManager.terminal = {
    programs.fd = {
      enable = true;
      hidden = true;

      ignores = [
        ".git/"
        ".devenv/"
        ".direnv/"
      ];

      extraOptions = [ "--follow" ];
    };
  };
}

