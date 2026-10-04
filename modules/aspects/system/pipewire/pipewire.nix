{
  flake.modules.nixos.pipewire = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.pavucontrol ];
    services.pipewire = {
      enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;

      jack.enable = true;
      pulse.enable = true;

      # wireplumber ships with pipewire.enable; only the codec tuning is
      # aspect-specific.
      wireplumber = {
        extraConfig = {
          "10-bluez"."monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "ldac" "aptx" "aptx_hd" ];
          };
        };
      };
    };
  };

  # Impermanence contribution for pipewire.
  # WirePlumber keeps its device selection in $XDG_STATE_HOME (effective
  # ~/.local/state/wireplumber): default-nodes, default-routes,
  # default-profile, stream-properties. Without persistence every boot falls
  # back to auto-priority — which ranks the internal speaker (~9900) above
  # the monitor (~5900), so the DP/HDMI sink silently loses "default".
  # PipeWire itself keeps no persistent state; one directory covers it all.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/state/wireplumber" ];
  };
}
