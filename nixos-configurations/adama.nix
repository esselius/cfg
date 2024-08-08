{ inputs, ezModules, config, ... }:

{
  _module.args.mkAuthentikScope = inputs.authentik-nix.lib.mkAuthentikScope;

  imports = [
    inputs.authentik-nix.nixosModules.default

    ezModules.authentik-blueprints
    ezModules.hardware-rpi5
    ezModules.profiles
    ezModules.sshd
    ezModules.user-peteresselius
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "24.05";

  context = "home";

  networking.firewall.allowedTCPPorts = [
    1883  # Mosquitto
    3000  # Grafana
    3030  # Loki
    8099  # Zigbee2MQTT
    9000  # Authentik
    9001  # Prometheus
    9100  # Node Exporter
    9121  # Redis Exporter
    9187  # Postgres Exporter
    9300  # Authentik Metrics
    28183 # Promtail
  ];

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
  };

  services.authentik.environmentFile = config.age.secrets.authentik-env.path;

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
    domain = "adama";
    oauth = {
      name = "Authentik";
      client_id_file = builtins.toFile "grafana-client-id" "grafana";
      client_secret_file = builtins.toFile "grafana-client-secret" "secret";
      auth_url = "http://adama:9000/application/o/authorize/";
      token_url = "http://adama:9000/application/o/token/";
      api_url = "http://adama:9000/application/o/userinfo/";
    };
  };
}
