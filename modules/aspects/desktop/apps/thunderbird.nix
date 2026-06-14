{
  flake.modules.homeManager.thunderbird = {
    programs.thunderbird = {
      enable = true;

      profiles.default = {
        isDefault = true;
      };

      settings = {
        # ─── Telemetry (Gecko-wide, identical keys as Firefox) ────────────────
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

        # ─── DoH (preferred, falls back to system DNS) ────────────────────────
        "network.trr.mode" = 2;

        # ─── Referer: strip to origin, same-domain only ───────────────────────
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;

        # ─── Beacon API + hyperlink ping tracking ─────────────────────────────
        "beacon.enabled" = false;
        "browser.send_pings" = false;

        # ─── Geolocation ──────────────────────────────────────────────────────
        "geo.enabled" = false;

        # ─── Disable JS execution inside PDFs ──
        "pdfjs.enableScripting" = false;

        # ─── Punycode spoofing protection (phishing links in mail) ────────────
        "network.IDN_show_punycode" = true;

        # ─── Language ─────────────────────────────────────────────────────────
        "spellchecker.dictionary" = "de_DE";
        "intl.accept_languages" = "de-DE, de, en-US, en";
      };
    };
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".thunderbird" ];
  };
}

