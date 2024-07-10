{ myModules, inputs, ... }:

{
  name = "monitoring-auth";

  nodes.machine = { modulesPath, ... }: {
    _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;

    virtualisation = {
      memorySize = 2048;
    };

    imports = [
      inputs.authentik-nix.nixosModules.default

      myModules.auth
      myModules.authentik-blueprints
      myModules.monitoring
    ];

    networking.firewall.enable = false;

    auth = {
      enable = true;
      env-file = builtins.toFile "authentik-env-file" ''
        AUTHENTIK_SECRET_KEY=qwerty123456
        AUTHENTIK_BOOTSTRAP_PASSWORD=password
        AUTHENTIK_BOOTSTRAP_TOKEN=token
      '';

    };
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
            redirect_uris = "http://localhost:3000/login/generic_oauth";
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
    monitoring = {
      enable = true;
      grafana = {
        domain = "localhost";
        oauth = {
          client_id_file = builtins.toFile "grafana-client-id" "grafana";
          client_secret_file = builtins.toFile "grafana-client-secret" "secret";
          auth_url = "http://127.0.0.1:9000/application/o/authorize/";
          token_url = "http://127.0.0.1:9000/application/o/token/";
          api_url = "http://127.0.0.1:9000/application/o/userinfo/";
        };
      };
    };
  };

  extraPythonPackages = p: [ p.playwright ];

  testScript = ''
    start_all()

    with subtest("Wait for authentik services to start"):
      machine.wait_for_unit("postgresql.service")
      machine.wait_for_unit("redis-authentik.service")
      machine.wait_for_unit("authentik-migrate.service")
      machine.wait_for_unit("authentik-worker.service")
      machine.wait_for_unit("authentik.service")

    with subtest("Wait for Authentik itself to initialize"):
      machine.wait_for_open_port(9000)
      machine.wait_until_succeeds("curl -fL http://localhost:9000/if/flow/initial-setup/ >&2")

    with subtest("Wait for Authentik blueprints to be applied"):
      machine.wait_until_succeeds("curl -f http://localhost:9000/application/o/grafana/.well-known/openid-configuration >&2")

    machine.forward_port(3000, 3000)
    machine.forward_port(9000, 9000)

    from playwright.sync_api import sync_playwright, expect

    with sync_playwright() as p:
      browser = p.chromium.launch()
      page = browser.new_page()

      with subtest("Login page"):
        page.goto("http://localhost:3000/login")
        page.reload()
        page.get_by_role("link", name="Sign in with Authentik").click()
      with subtest("Enter username"):
        page.get_by_placeholder("Email or Username").fill("akadmin")
        page.get_by_role("button", name="Log in").click()
      with subtest("Enter password"):
        page.get_by_placeholder("Please enter your password").fill("password")
        page.get_by_role("button", name="Continue").click()
      with subtest("Consent page"):
        page.get_by_role("button", name="Continue").click()
      with subtest("Grafana landing page"):
        expect(page.get_by_role("heading", name="Starred dashboards")).to_be_visible()

      browser.close()
  '';
}
