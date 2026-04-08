{
  flake.modules.homeManager.rustscan = { pkgs, ... }: {
    home.packages = with pkgs; [ nmap rustscan ];
  };
}
