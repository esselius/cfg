{ myModules, inputs, ... }:

{
  name = "monitoring-auth";

  nodes.machine = { pkgs, ... }: {
    _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;

    virtualisation = {
      cores = 6;
      memorySize = 8192;
    };

    imports = [
      inputs.authentik-nix.nixosModules.default

      myModules.authentik-blueprints
      myModules.profiles
    ];

    networking.firewall.enable = false;

    profiles.auth = {
      enable = true;
      domain = "localhost";
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
    profiles.monitoring = {
      enable = true;
      domain = "localhost";
      oauth = {
        name = "Authentik";
        client_id_file = builtins.toFile "grafana-client-id" "grafana";
        client_secret_file = builtins.toFile "grafana-client-secret" "secret";
        auth_url = "http://localhost:9000/application/o/authorize/";
        token_url = "http://localhost:9000/application/o/token/";
        api_url = "http://localhost:9000/application/o/userinfo/";
      };
    };

    environment.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
    };

    environment.systemPackages = [
      (pkgs.writers.writePython3Bin "test_auth" {
        libraries = [pkgs.python3Packages.playwright];
      } ''
        from playwright.sync_api import sync_playwright, expect

        with sync_playwright() as p:
            browser = p.chromium.launch()

            context = browser.new_context()
            context.set_default_timeout(30000)
            context.tracing.start(screenshots=True, snapshots=True)
            page = context.new_page()

            try:
                print("Login page")
                page.goto("http://localhost:3000/login")
                # page.reload()
                page.get_by_role("link", name="Sign in with Authentik").click()

                print("Enter username")
                page.get_by_placeholder("Email or Username").fill("akadmin")
                page.get_by_role("button", name="Log in").click()

                # page.reload()
                print("Enter password")
                page.get_by_placeholder("Please enter your password").fill("password")
                page.get_by_role("button", name="Continue").click()

                print("Consent page")
                page.get_by_role("button", name="Continue").click()

                print("Grafana landing page")
                x = expect(page.get_by_role("heading", name="Starred dashboards"))
                x.to_be_visible()
            except Exception as e:
                raise e
            finally:
                context.tracing.stop(path="/tmp/trace.zip")
                context.close()
                browser.close()
      '')
    ];
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

    with subtest("Test auth"):
      ret, output = machine.execute("test_auth")
      print(output)

      if ret != 0:
        machine.copy_from_vm("/tmp/trace.zip", ".")
        exit(1)
  '';
}
