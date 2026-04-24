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

        settings = {
          # ─── Telemetry ────────────────────────────────────────────────────────
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

          # ─── Tracking protection (covers trackers/fingerprinters/cookies) ─────
          "browser.contentblocking.category" = "strict";

          # ─── HTTPS-Only ───────────────────────────────────────────────────────
          "dom.security.https_only_mode" = true;

          # ─── DoH (preferred, falls back to system DNS) ────────────────────────
          "network.trr.mode" = 2;

          # ─── Referer: only send on same base domain, strip to origin ──────────
          "network.http.referer.XOriginPolicy" = 2;
          "network.http.referer.XOriginTrimmingPolicy" = 2;

          # ─── WebRTC IP-leak protection ────────────────────────────────────────
          # default_address_only is sufficient; no_host breaks LAN WebRTC (Jellyfin etc.)
          "media.peerconnection.ice.default_address_only" = true;

          # ─── Beacon API (used by analytics to fire-and-forget on page unload) ─
          "beacon.enabled" = false;

          # ─── Hyperlink ping tracking (<a ping>) ───────────────────────────────
          "browser.send_pings" = false;

          # ─── Geolocation ──────────────────────────────────────────────────────
          "geo.enabled" = false;

          # ─── Speculative pre-connect for URL bar autocomplete ─────────────────
          "browser.urlbar.speculativeConnect.enabled" = false;

          # ─── Disable JS execution inside PDFs ────────────────────────────────
          "pdfjs.enableScripting" = false;

          # ─── Disable autoplay ─────────────────────────────────────────────────
          "media.autoplay.enabled" = false;

          # ─── Mozilla ads / sponsored content / Pocket ─────────────────────────
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.trending.featureGate" = false;
          "extensions.pocket.enabled" = false;

          # ─── Disable DNT header (is itself a fingerprinting vector) ──────────
          "privacy.donottrackheader.enabled" = false;

          # ─── UI cruft ─────────────────────────────────────────────────────────
          "browser.uitour.enabled" = false;

          # ─── Container tabs ───────────────────────────────────────────────────
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;

          # ─── Punycode spoofing protection ─────────────────────────────────────
          "network.IDN_show_punycode" = true;

          # ─── Vertical tab strip ─────────
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "expand-on-hover";

          # ─── Homepage ─────────────────────────────────────────────────────────
          "browser.startup.page" = 1;
          "browser.startup.homepage" = "https://claude.ai|https://github.com";

          # ─── Spellcheck: German dictionary ────────────────────────────────────
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

    home =
      let
        dicts = with pkgs.hunspellDicts; [ de_DE en_US ru_RU ];
      in
      {
        packages = [ pkgs.hunspell ] ++ dicts;
        sessionVariables.DICPATH = lib.concatMapStringsSep ":" (d: "${d}/share/hunspell") dicts;
      };

    stylix.targets.firefox.profileNames = [ "default" ];
    stylix.targets.firefox.colorTheme.enable = true;
  };
}

