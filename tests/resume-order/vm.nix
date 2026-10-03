{ pkgs, library }:
let
  delayedResume = {
    description = "Synthetic delayed hibernate resume for ordering test";
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      touch /run/resume-started
      sleep 8
      touch /run/resume-finished
    '';
  };

  rollbackProbe = {
    description = "Non-destructive rollback ordering probe";
    wantedBy = [ "initrd.target" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";
    script = ''
      if test -e /run/resume-finished; then
        echo completed > /run/rollback-observed
      elif test -e /run/resume-started; then
        echo in-progress > /run/rollback-observed
      else
        echo not-started > /run/rollback-observed
      fi
    '';
  };

  probeNode = {
    boot.initrd.systemd.enable = true;
    boot.resumeDevice = "/dev/vda";
    boot.initrd.systemd.services.systemd-hibernate-resume = delayedResume;
    boot.initrd.systemd.services.rollback-probe = rollbackProbe;
  };
in
pkgs.testers.runNixOSTest {
  name = "initrd-resume-order";

  nodes = {
    baseline = _: probeNode;

    ordered = { lib, ... }: {
      imports = [
        library.inputs.agenix.nixosModules.default
        library.inputs.home-manager.nixosModules.home-manager
        library.nixosModules.impermanence
      ];
      boot = {
        initrd.systemd.enable = true;
        resumeDevice = "/dev/vda";
        initrd.systemd.services.systemd-hibernate-resume = delayedResume;
        initrd.systemd.services.rollback-root.script = lib.mkForce rollbackProbe.script;
      };
    };

    cold = _: {
      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.services.rollback-probe = {
        description = "Non-destructive cold-boot rollback ordering probe";
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        script = ''
          if systemctl is-active --quiet systemd-hibernate-resume.service; then
            echo unexpectedly-active > /run/rollback-observed
          else
            echo no-resume > /run/rollback-observed
          fi
        '';
      };
    };
  };

  testScript = ''
    baseline.start()
    ordered.start()
    cold.start()
    baseline.wait_for_unit("multi-user.target")
    ordered.wait_for_unit("multi-user.target")
    cold.wait_for_unit("multi-user.target")

    baseline.succeed("test \"$(cat /run/rollback-observed)\" = not-started")
    baseline.succeed("test -e /run/resume-finished")
    ordered.succeed("test \"$(cat /run/rollback-observed)\" = completed")
    cold.succeed("test \"$(cat /run/rollback-observed)\" = no-resume")
    print("baseline rollback observation: " + baseline.succeed("cat /run/rollback-observed").strip())
    print("ordered rollback observation: " + ordered.succeed("cat /run/rollback-observed").strip())
    print("cold rollback observation: " + cold.succeed("cat /run/rollback-observed").strip())
  '';
}
