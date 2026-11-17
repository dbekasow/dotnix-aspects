{
  # Conventional resource layout: every *.crt below
  # modules/hosts/<host>/certificates/ is trusted as an extra root CA.
  # Consumers deviate by setting the native `security.pki.certificateFiles`.
  dotnix.host.certificates.includes = [
    ({ inputs, host, lib, ... }: {
      name = "certificates/conventional";
      nixos.security.pki.installCACerts = lib.mkDefault true;
      nixos.security.pki.certificateFiles = lib.mkDefault (
        let
          certDir = "${inputs.self}/modules/hosts/${host.hostName}/certificates";
        in
        lib.optionals (lib.pathExists certDir)
          (lib.filter (lib.hasSuffix ".crt")
            (lib.filesystem.listFilesRecursive certDir))
      );
    })
  ];
}
