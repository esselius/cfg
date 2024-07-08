{ inputs, ezModules, config, ... }:

{
  imports = [
    ezModules.hardware-rpi5
    ezModules.sshd
    ezModules.user-peteresselius
    ezModules.auth
    ezModules.monitoring
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "home";

  networking.firewall.allowedTCPPorts = [ 3000 9000 ];

  age.secrets.authentik-env.file = ../secrets/authentik-env.age;
  auth = {
    enable = true;
    env-file = config.age.secrets.authentik-env.path;
    blueprints = [{
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
  monitoring = {
    enable = true;
    grafana = {
      domain = "adama";
      oauth = {
        client_id_file = builtins.toFile "grafana-client-id" "grafana";
        client_secret_file = builtins.toFile "grafana-client-secret" "secret";
        auth_url = "http://adama:9000/application/o/authorize/";
        token_url = "http://adama:9000/application/o/token/";
        api_url = "http://adama:9000/application/o/userinfo/";
      };
    };
  };
}
