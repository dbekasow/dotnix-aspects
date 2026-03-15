{ inputs, ... }: {
  flake.modules.nixos.core = { lib, ... }: with lib; {

    security.pki.certificateFiles =
      let
        certDir = "${inputs.self}/certificates";
        certFiles = optionals (pathExists certDir) (pipe certDir [
          filesystem.listFilesRecursive
          (filter (hasSuffix ".crt"))
        ]);
      in
      certFiles;
  };
}
