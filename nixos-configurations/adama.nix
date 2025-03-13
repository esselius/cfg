{ inputs, ezModules, config, ... }:

{
  _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;

  imports = [
    ezModules.authentik-blueprints
    ezModules.hardware-rpi5
    ezModules.sshd
    ezModules.user-peteresselius
    ezModules.ca
    ezModules.nginx
    ezModules.prometheus-mqtt-exporter
    ezModules.nix-gc
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "home";
  formfactor = "server";

  networking.firewall.allowedTCPPorts = [
    443 # Nginx
    # 1880 # Node-RED
    1883 # Mosquitto
    # 3000 # Grafana
    # 3030 # Loki
    # 6052 # ESPHome
    # 8099 # Zigbee2MQTT
    8443 # Step CA
    # 9000 # Authentik
    # 9001 # Prometheus
    # 9100 # Node Exporter
    # 9121 # Redis Exporter
    # 9187 # Postgres Exporter
    # 9300 # Authentik Metrics
    # 28183 # Promtail
  ];

  age.secrets.grafana-env.file = ../secrets/grafana-env.age;
  age.secrets.authentik-env.file = ../secrets/authentik-env.age;
  age.secrets.z2m = {
    name = "z2m.yaml";
    file = ../secrets/z2m.age;
    owner = "zigbee2mqtt";
    group = "zigbee2mqtt";
  };

  profiles.smarthome = {
    enable = true;
  };

  profiles.auth = {
    enable = true;
    domain = "authentik.adama.lan";
  };

  services.authentik.environmentFile = config.age.secrets.authentik-env.path;

  services.authentik.blueprints = [
    {
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
    }
    {
      metadata.name = "nodered-oauth";
      entries = [
        {
          model = "authentik_providers_oauth2.oauth2provider";
          state = "present";
          identifiers.name = "Node-RED";
          id = "provider";
          attrs = {
            authentication_flow = "!Find [authentik_flows.flow, [slug, default-authentication-flow]]";
            authorization_flow = "!Find [authentik_flows.flow, [slug, default-provider-authorization-explicit-consent]]";
            client_type = "confidential";
            client_id = "node-red";
            client_secret = "secret";
            access_code_validity = "minutes=1";
            access_token_validity = "minutes=5";
            refresh_token_validity = "days=30";
            property_mappings = [
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, openid]]"
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, email]]"
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, profile]]"
            ];
            sub_mode = "hashed_user_id";
            include_claims_in_id_token = true;
            issuer_mode = "per_provider";
          };
        }
        {
          model = "authentik_core.application";
          state = "present";
          identifiers.slug = "node-red";
          id = "node-red";
          attrs = {
            name = "Node-RED";
            provider = "!KeyOf provider";
            policy_engine_mode = "any";
          };
        }
      ];
    }
    {
      metadata.name = "pgadmin-oauth";
      entries = [
        {
          model = "authentik_providers_oauth2.oauth2provider";
          state = "present";
          identifiers.name = "pgAdmin";
          id = "provider";
          attrs = {
            authentication_flow = "!Find [authentik_flows.flow, [slug, default-authentication-flow]]";
            authorization_flow = "!Find [authentik_flows.flow, [slug, default-provider-authorization-explicit-consent]]";
            client_type = "confidential";
            client_id = "pgadmin";
            client_secret = "secret";
            access_code_validity = "minutes=1";
            access_token_validity = "minutes=5";
            refresh_token_validity = "days=30";
            property_mappings = [
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, openid]]"
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, email]]"
              "!Find [authentik_providers_oauth2.scopemapping, [scope_name, profile]]"
            ];
            sub_mode = "hashed_user_id";
            include_claims_in_id_token = true;
            issuer_mode = "per_provider";
          };
        }
        {
          model = "authentik_core.application";
          state = "present";
          identifiers.slug = "pgadmin";
          id = "pgadmin";
          attrs = {
            name = "pgAdmin";
            provider = "!KeyOf provider";
            policy_engine_mode = "any";
          };
        }
      ];
    }
  ];

  profiles.monitoring = {
    enable = true;
    domain = "grafana.adama.lan";
    root_url = "https://grafana.adama.lan/";
    oauth = {
      name = "Authentik";
      client_id_file = builtins.toFile "grafana-client-id" "grafana";
      client_secret_file = builtins.toFile "grafana-client-secret" "secret";
      auth_url = "https://authentik.adama.lan/application/o/authorize/";
      token_url = "https://authentik.adama.lan/application/o/token/";
      api_url = "https://authentik.adama.lan/application/o/userinfo/";
    };
  };
  services.prometheus = {
    scrapeConfigs = [
      { job_name = "starbuck-node-exporter"; static_configs = [{ targets = [ "starbuck:9100" ]; }]; }
      { job_name = "openwrt"; static_configs = [{ targets = [ "192.168.1.1:9100" "192.168.1.2:9100" ]; }]; }
    ];
  };

  services.cockpit = {
    enable = true;
    openFirewall = true;
    port = 8085;
  };
}
