{ config, ... }:

{
  age.secrets.step-ca.rekeyFile = ../secrets/step-ca.age;

  services.step-ca = {
    enable = true;

    port = 8443;
    address = "0.0.0.0";

    intermediatePasswordFile = config.age.secrets.step-ca.path;

    settings = {
      root = "/var/lib/step-ca/certs/root_ca.crt";
      crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
      key = "/var/lib/step-ca/secrets/intermediate_ca_key";

      dnsNames = [ "adama" ];

      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
      };

      authority.provisioners = [{
        type = "ACME";
        name = "my-acme-provisioner";
      }];
    };
  };
}
