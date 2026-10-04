{ inputs, ... }: {
  dotnix.certificates.nixos = { host, lib, ... }: with lib; {
    security.pki.certificateFiles =
      let
        certDir = "${inputs.self}/modules/hosts/${host.name}/certificates";
        certFiles = optionals (pathExists certDir) (pipe certDir [
          filesystem.listFilesRecursive
          (filter (hasSuffix ".crt"))
        ]);
      in
      certFiles;
  };
}
