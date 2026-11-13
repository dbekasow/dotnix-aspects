{
  dotnix.home.herdr.homeManager =
    { config
    , lib
    , pkgs
    , ...
    }:
    let
      # A linked plugin is a directory with herdr-plugin.toml at its root;
      # `herdr plugin link` registers it without running the manifest's
      # [[build]] step, so the binary comes from here and $out doubles as
      # the plugin root. Vendored pattern: lorenzorapetti/herdr-nix.
      herdr-auto-title = pkgs.buildGoModule {
        pname = "herdr-auto-title";
        version = "0.22.2";
        src = pkgs.fetchFromGitHub {
          owner = "kryptamine";
          repo = "herdr-auto-title";
          rev = "v0.22.2";
          hash = "sha256-ebLE7rkpENQJpGs4gYO2G96n29S6Jt5kQ2zk7JQ3WXk=";
        };
        vendorHash = "sha256-UfIpYaA2eIRl29fhi7ESEoHEsyiXmEZ4MO78T0Q6OCs=";
        doCheck = false;
        postInstall = ''
          install -Dm644 herdr-plugin.toml $out/herdr-plugin.toml
          ln -s bin/herdr-auto-title $out/herdr-auto-title
        '';
        meta = {
          description = "Contextual tab and pane titles for herdr";
          homepage = "https://github.com/kryptamine/herdr-auto-title";
          license = lib.licenses.mit;
          mainProgram = "herdr-auto-title";
        };
      };
    in
    {
      # herdr-auto-title owns tab names; a name typed into the new-tab
      # prompt counts as manual and puts the tab beyond its reach.
      programs.herdr.settings.ui.prompt_new_tab_name = lib.mkDefault false;

      # Declarative plugin registration: link is an idempotent upsert keyed
      # on the plugin id, and startup hooks only run at server bootstrap, so
      # poke the restart action for a running server. Best effort — neither
      # a missing server nor a missing herdr may break activation.
      home.activation.herdrAutoTitle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe config.programs.herdr.package} plugin link ${herdr-auto-title} >/dev/null 2>&1 || true
        run ${lib.getExe config.programs.herdr.package} plugin action invoke herdr.auto-title.restart >/dev/null 2>&1 || true
      '';
    };

  # auto-title's own config dir: manual-names.json keeps hand-set names
  # (and the ones it generated) across reboots, so a restart does not mistake
  # yours for generated ones; plus its single-instance claim file.
  dotnix.home.herdr.homePersistence = {
    home.persistence."/persist".directories = [ ".config/herdr-auto-title" ];
  };
}
