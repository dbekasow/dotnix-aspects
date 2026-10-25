{
  # Consumers provide certificate resources with the native
  # `security.pki.certificateFiles` option.
  dotnix.host.certificates.nixos = { lib, ... }: {
    security.pki.installCACerts = lib.mkDefault true;
  };
}
