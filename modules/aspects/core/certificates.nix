{ inputs, ... }: {
  flake.modules.nixos.core = { config, lib, ... }: with lib; {
    security.pki.certificateFiles =
      let
        certDir = "${inputs.self}/modules/hosts/${config.dotnix.hostname}/certificates";
        certFiles = optionals (pathExists certDir) (pipe certDir [
          filesystem.listFilesRecursive
          (filter (hasSuffix ".crt"))
        ]);
      in
      certFiles;
  };
}
