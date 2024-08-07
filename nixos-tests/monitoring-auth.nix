{ myModules, inputs, ... }:

{
  name = "monitoring-auth";

  nodes.monitoring = { modulesPath, pkgs, ...}: {
    virtualisation = {
      memorySize = 2048;
      forwardPorts = [
        { host.port = 3000; guest.port = 3000; }
      ];
    };

    imports = [
      inputs.authentik-nix.nixosModules.default

      myModules.profiles
      (modulesPath + "/../tests/common/user-account.nix")
    ];

    networking.firewall.enable = false;

    profiles.monitoring = {
      enable = true;
      domain = "monitoring";
      oauth = {
        name = "Authentik";
        client_id_file = builtins.toFile "grafana-client-id" "grafana";
        client_secret_file = builtins.toFile "grafana-client-secret" "secret";
        auth_url = "http://auth:9000/application/o/authorize/";
        token_url = "http://auth:9000/application/o/token/";
        api_url = "http://auth:9000/application/o/userinfo/";
      };
    };

    environment.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
    };

    environment.systemPackages = [
      (pkgs.writers.writePython3Bin "test_auth"
        {
          libraries = [ pkgs.python3Packages.playwright ];
        } (builtins.readFile ./monitoring-auth.py))
    ];
  };

  nodes.auth = { modulesPath, ...}: {
    _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;

    virtualisation = {
      cores = 3;
      memorySize = 4096;
      forwardPorts = [
        { host.port = 9000; guest.port = 9000; }
      ];
    };

    imports = [
      inputs.authentik-nix.nixosModules.default

      myModules.authentik-blueprints
      myModules.profiles
      (modulesPath + "/../tests/common/user-account.nix")
    ];

    networking.firewall.enable = false;

    profiles.auth = {
      enable = true;
      domain = "auth";
    };

    services.authentik.environmentFile = builtins.toFile "authentik-env-file" ''
      AUTHENTIK_SECRET_KEY=qwerty123456
      AUTHENTIK_BOOTSTRAP_PASSWORD=password
      AUTHENTIK_BOOTSTRAP_TOKEN=token
      AUTHENTIK_DISABLE_STARTUP_ANALYTICS=true
      AUTHENTIK_DISABLE_UPDATE_CHECK=true
      AUTHENTIK_ERROR_REPORTING__ENABLED=false
    '';

    services.authentik.blueprints = [{
      metadata.name = "grafana-oauth";
      entries = [
        {
          model = "authentik_providers_oauth2.oauth2provider";
          state = "present";
          identifiers.name = "Grafana";
          id = "provider";
          attrs = {
            authentication_flow = "!Find [authentik_flows.flow, [slug, default-authentication-flow]]";
            authorization_flow = "!Find [authentik_flows.flow, [slug, default-provider-authorization-explicit-consent]]";
            client_type = "confidential";
            client_id = "grafana";
            client_secret = "secret";
            access_code_validity = "minutes=1";
            access_token_validity = "minutes=5";
            refresh_token_validity = "days=30";
            property_mappings = [
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, openid]]"
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, email]]"
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, profile]]"
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, offline_access]]"
            ];
            sub_mode = "hashed_user_id";
            include_claims_in_id_token = true;
            issuer_mode = "per_provider";
            redirect_uris = "http://monitoring:3000/login/generic_oauth";
          };
        }
        {
          model = "authentik_core.application";
          state = "present";
          identifiers.slug = "grafana";
          id = "grafana";
          attrs = {
            name = "Grafana";
            provider = "!KeyOf provider";
            policy_engine_mode = "any";
          };
        }
      ];
    }];
  };

  testScript = ''
    start_all()

    with subtest("Wait for authentik services to start"):
      auth.wait_for_unit("postgresql.service")
      auth.wait_for_unit("redis-authentik.service")
      auth.wait_for_unit("authentik-migrate.service")
      auth.wait_for_unit("authentik-worker.service")
      auth.wait_for_unit("authentik.service")

    with subtest("Wait for Authentik itself to initialize"):
      auth.wait_for_open_port(9000)
      auth.wait_until_succeeds("curl -fL http://localhost:9000 >&2")
      auth.wait_until_succeeds("curl -fL http://localhost:9000/flows/-/default/authentication/ >&2")

    with subtest("Wait for Authentik blueprints to be applied"):
      auth.wait_until_succeeds("curl -f http://localhost:9000/application/o/grafana/.well-known/openid-configuration >&2")

    with subtest("Test auth"):
      ret, output = monitoring.execute("test_auth")
      print(output)

      if ret != 0:
        monitoring.copy_from_vm("/tmp/trace.zip", ".")
        exit(1)
  '';
}
