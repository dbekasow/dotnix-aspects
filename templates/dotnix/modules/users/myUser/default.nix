{ self, ... }:
let hm = self.modules.homeManager; in {
  flake.modules = let user = "myuser"; in {
    nixos."${user}" = {
      users.users."${user}" = {
        extraGroups = [ "wheel" "networkmanager" ];
      };

      home-manager.users."${user}".imports = [
        hm."${user}"
      ];
    };

    homeManager."${user}".imports = with hm; [
      terminal # shells, tools, multiplexer
      development # editor, vcs, automation
    ];

    generic."${user}".profile = {
      fullname = "Full Name";
      email = "user@example.com";
    };
  };
}
