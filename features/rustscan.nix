{
  dotnix.home.rustscan.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ nmap rustscan ];
  };
}
