{
  flake.modules.homeManager.firefox = { lib, pkgs, ... }: {
    programs.firefox = {
      enable = true;

      profiles.default = {
        isDefault = true;

        search = {
          default = "google";
          privateDefault = "ddg";
          force = true;
        };

        # Delta-audited against Firefox release defaults: every entry is a
        # real delta or a deliberate personal preference. Upstream defaults
        # stay unwritten so pref drift against Mozilla stays visible here.
        settings = {
          # Telemetry: Mozilla ships this active. A few entries sit at their
          # release default, but Normandy/rollout experiments can flip prefs
          # remotely, so the whole floor stays explicit.
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.server" = "";
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "devtools.onboarding.telemetry.logged" = false;

          # Tracking/network hardening — upstream defaults are weaker in
          # every case (standard blocking, plain HTTP, referer 0/0, TRR
          # off, geolocation and beacons on).
          "browser.contentblocking.category" = "strict";
          "dom.security.https_only_mode" = true;
          "network.trr.mode" = 2; # DoH preferred, system DNS as fallback
          "network.http.referer.XOriginPolicy" = 2;
          "network.http.referer.XOriginTrimmingPolicy" = 2;
          # default_address_only is sufficient; no_host breaks LAN WebRTC (Jellyfin etc.)
          "media.peerconnection.ice.default_address_only" = true;
          "beacon.enabled" = false;
          "geo.enabled" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;
          "network.IDN_show_punycode" = true;

          # Mozilla ads / sponsored content / Pocket: shipped on upstream.
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          # Release default is already off, but quicksuggest rollout
          # experiments have flipped it before — keep the floor explicit.
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.trending.featureGate" = false;
          "extensions.pocket.enabled" = false;

          # Container tabs: functionality ships enabled, only the UI entries
          # are hidden upstream — surfacing them is deliberate.
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;

          # Passwords/form autofill: Bitwarden owns credentials, so Firefox's
          # own store stays off (all of these ship on by default).
          "signon.rememberSignons" = false;
          "signon.autofillForms" = false;
          "signon.generation.enabled" = false;
          "signon.management.page.breach-alerts.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "browser.formfill.enable" = false;

          # Personal preferences, not privacy deltas.
          "sidebar.revamp" = true; # new sidebar with the vertical tab strip
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "expand-on-hover";
          "browser.startup.page" = 1; # open the homepage below on startup
          "browser.startup.homepage" = "https://claude.ai|https://github.com";
          "spellchecker.dictionary" = "de_DE";
          "intl.accept_languages" = "de-DE, de, en-US, en";
        };

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          i-dont-care-about-cookies
          localcdn
          multi-account-containers
          private-relay
          ublock-origin
        ];
        extensions.force = true;
      };

      languagePacks = [ "en-US" "de" ];
    };

    home = let dicts = with pkgs.hunspellDicts; [ de_DE en_US ru_RU ]; in {
      packages = [ pkgs.hunspell ] ++ dicts;
      sessionVariables.DICPATH = lib.concatMapStringsSep ":" (d: "${d}/share/hunspell") dicts;
    };

    stylix.targets.firefox.profileNames = [ "default" ];
    stylix.targets.firefox.colorTheme.enable = true;
  };

  flake.modules.homeManager.niri.programs.niri.settings.window-rules = [
    {
      # Firefox uses CSDs that break clip-to-geometry — disable the global rule
      matches = [{ app-id = "firefox$"; }];
      clip-to-geometry = false;
    }
    {
      # PiP window: floating, pinned to top-right corner
      matches = [{ app-id = "firefox$"; title = "^Picture-in-Picture$"; }];
      open-floating = true;
      default-floating-position = { x = 32; y = 32; relative-to = "top-right"; };
    }
  ];

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".config/mozilla" ];
  };
}

