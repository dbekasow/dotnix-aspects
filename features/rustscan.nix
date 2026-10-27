{
  dotnix.rustscan.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ nmap rustscan ];
  };
}
