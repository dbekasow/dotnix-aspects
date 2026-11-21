{ niri }:
{ lib, specialArgs, ... }:
{
  # Host Niri already provides the Home Manager settings options. Otherwise
  # both home.niri and home.dms use this same keyed fallback provider.
  imports = lib.optional (!((specialArgs.osConfig or { }) ? niri-flake)) {
    key = "${niri}/homeModules/niri";
    imports = [ niri.homeModules.niri ];
  };
}
