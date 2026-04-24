{
  flake.modules.homeManager.firefox = { pkgs, ... }: {
    programs.firefox = {
      enable = true;

      profiles.default = {
        isDefault = true;

        settings = {
          # --- Telemetry & Data Collection ---
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "browser.ping-centre.telemetry" = false;

          # --- Studies & Experiments ---
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;

          # --- Crash Reports ---
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;

          # --- Tracking Protection ---
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.enabled" = true;

          # --- First Party Isolation ---
          "privacy.firstparty.isolate" = true;

          # --- Fingerprinting Resistance ---
          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.block_mozAddonManager" = true;

          # --- WebRTC (IP leak prevention) ---
          "media.peerconnection.ice.default_address_only" = true;
          "media.peerconnection.ice.no_host" = true;

          # --- Safe Browsing (sends URLs to Google) ---
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;

          # --- Sponsored Content & Pocket ---
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "extensions.pocket.enabled" = false;

          # --- HTTPS Only Mode ---
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;

          # --- Cookies ---
          "network.cookie.cookieBehavior" = 1;
          "network.cookie.lifetimePolicy" = 2;

          # --- History ---
          "privacy.history.custom" = true;
          "places.history.enabled" = false;
        };

        extensions.packages = with pkgs; [ ];
      };

      languagePacks = [ "en-US" "de" ];
    };

    stylix.targets.firefox.profileNames = [ "default" ];
  };
}

