{
  security.pki.certificateFiles = [ ../root_ca.crt ];

  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "hello@you.com";
      server = "https://adama:8443/acme/my-acme-provisioner/directory";
    };
  };

  services.nginx = {
    enable = true;

    statusPage = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
  };
}
