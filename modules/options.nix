{ lib, config, ... }: with lib.types;
let
  inherit (config.flake) modules;

  hostSubModule = submoduleWith {
    specialArgs = { inherit (modules) nixos homeManager; };
    modules = [{
      options = {
        system = lib.mkOption { type = str; default = "x86_64-linux"; };
        modules = lib.mkOption { type = listOf deferredModule; default = [ ]; };
        members = lib.mkOption { type = attrsOf userSubModule; default = { }; };
      };
    }];
  };

  userSubModule = submoduleWith {
    specialArgs = { inherit (modules) homeManager; };
    modules = [{
      options = {
        email = lib.mkOption { type = nullOr str; default = null; };
        fullname = lib.mkOption { type = nullOr str; default = null; };
        isNormalUser = lib.mkOption { type = bool; default = true; };
        extraGroups = lib.mkOption { type = listOf str; default = [ "wheel" ]; };
        modules = lib.mkOption { type = listOf deferredModule; default = [ ]; };
        theme = lib.mkOption { type = str; default = "catppuccin-mocha"; };
        repositories = lib.mkOption { type = listOf repositories; default = [ ]; };
      };
    }];
  };

  repositories = submodule {
    options = {
      url = lib.mkOption { type = str; };
      projects = lib.mkOption { type = listOf str; };
      destination = lib.mkOption { type = str; default = "repositories"; };
      branch = lib.mkOption { type = str; default = "main"; };
    };
  };
in
{
  options.dotnix = lib.mkOption {
    type = submodule {
      options = {
        hosts = lib.mkOption { type = attrsOf hostSubModule; default = { }; };
        users = lib.mkOption { type = attrsOf userSubModule; default = { }; };
      };
    };
    description = "Dotnix configuration namespace";
    default = { };
  };

  config.flake.modules.nixos.core = {
    options.dotnix = {
      hostname = lib.mkOption { type = str; default = null; };
      host = lib.mkOption { type = hostSubModule; default = { }; };
    };
  };

  config.flake.modules.homeManager.core = {
    options.dotnix = {
      username = lib.mkOption { type = str; default = null; };
      user = lib.mkOption { type = userSubModule; default = { }; };
    };
  };
}
