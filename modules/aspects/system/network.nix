{
  flake.modules.nixos.network = { lib, pkgs, ... }: {
    networking = {
      networkmanager = {
        enable = true;
        dhcp = "internal";

        # Was "default" before: NixOS's NM module then renders a
        # [global-dns-domain-*] block from networking.nameservers. Result:
        # EVERY lookup went to Cloudflare uncached, the DHCP-provided DNS was
        # ignored, and local names (fritz.box, VPN split-DNS) failed to
        # resolve.
        dns = "systemd-resolved";

        plugins = [ pkgs.networkmanager-openvpn ];
      };

      # mkForce, otherwise the global-dns override from before still applies.
      # With resolved, networking.nameservers would also become DNS= in
      # resolved.conf and outrank whatever DHCP hands us.
      nameservers = lib.mkForce [ ];

      nftables.enable = true;

      useDHCP = false;
      dhcpcd.enable = false;

      firewall.enable = true;
    };

    # Local DNS cache. Over WLAN with ~30 ms RTT, this saves roughly as many
    # round trips as a typical page has domains (often 15+).
    #
    # NOTE: services.resolved.extraConfig was removed from nixpkgs; the
    # resolved.conf [Resolve] section is now a freeform attrset under
    # settings.Resolve. The old fallbackDns / dnssec / dnsovertls / domains
    # options are renamed aliases into the same place, so keep everything
    # here to avoid deprecation warnings.
    services.resolved = {
      enable = true;

      settings.Resolve = {
        # Cache is the whole point of running resolved here.
        Cache = "yes";
        CacheFromLocalhost = "no";
        ReadEtcHosts = "yes";

        # avahi handles .local via nssmdns4 — otherwise both fight over it.
        MulticastDNS = "no";
        LLMNR = "no";

        # "opportunistic"/"allow-downgrade" rather than strict: a laptop hits
        # captive portals, and strict DNSSEC/DoT makes those unusable.
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "opportunistic";

        # Only used when the network provides no DNS of its own. Deliberately
        # not Domains = [ "~." ], so the DHCP resolver stays in charge for
        # local and VPN names.
        FallbackDNS = [
          "1.1.1.1#cloudflare-dns.com"
          "1.0.0.1#cloudflare-dns.com"
        ];
      };
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      # publish was on: a laptop broadcasting mDNS records into an unknown
      # WLAN is unnecessary broadcast traffic and an info leak.
      publish.enable = false;
    };

    environment.systemPackages = with pkgs; [ curl dig ];
  };

  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".directories = [
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
    ];
  };
}
