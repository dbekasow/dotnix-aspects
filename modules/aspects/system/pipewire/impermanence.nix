# Impermanence contribution for pipewire — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# WirePlumber keeps its device selection in $XDG_STATE_HOME (effective
# ~/.local/state/wireplumber): default-nodes, default-routes,
# default-profile, stream-properties. Without persistence every boot falls
# back to auto-priority — which ranks the internal speaker (~9900) above
# the monitor (~5900), so the DP/HDMI sink silently loses "default".
# PipeWire itself keeps no persistent state; one directory covers it all.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/state/wireplumber" ];
  };
}
