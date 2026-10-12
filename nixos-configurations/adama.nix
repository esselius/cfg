{ config, ... }:

{
  imports = [
    ../nixos-modules/authentik-blueprints.nix
    ../nixos-modules/sshd.nix
    ../nixos-modules/user-peteresselius.nix
    ../nixos-modules/ca.nix
    ../nixos-modules/nginx.nix
    ../nixos-modules/nix-gc.nix
    ../nixos-modules/hardware-rpi5.nix
    ../nixos-modules/wireguard.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "adama";
  system.stateVersion = "24.05";

  context = "home";
  formfactor = "server";
  mainUser = "peteresselius";

  hardware-rpi5 = {
    enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    443 # Nginx
    # 1880 # Node-RED
    1883 # Mosquitto
    # 3000 # Grafana
    # 3030 # Loki
    # 6052 # ESPHome
    8099 # Zigbee2MQTT
    8443 # Step CA
    # 9000 # Authentik
    # 9001 # Prometheus
    # 9100 # Node Exporter
    # 9121 # Redis Exporter
    # 9187 # Postgres Exporter
    # 9300 # Authentik Metrics
    # 28183 # Promtail
  ];

  age.secrets = {
    grafana-env.rekeyFile = ../secrets/grafana-env.age;
    authentik-env.rekeyFile = ../secrets/authentik-env.age;
    wg-private-key.rekeyFile = ../secrets/wg-private-key.adama.age;
    z2m = {
      name = "z2m.yaml";
      rekeyFile = ../secrets/z2m.age;
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
    };
  };

  wireguard-vpn = {
    enable = true;
    # Split-tunnel node on the router's WireGuard server (not a full-tunnel
    # client): only the VPN subnet routes via wg0. The Pi (and its incus
    # bridges) are reached directly over the LAN via extraPeers, so that
    # traffic no longer hairpins through the router.
    address = "10.6.0.5/32";
    privateKeySecret = "wg-private-key";
    serverPublicKey = "b+Xgh4RNJl20tlnb41DQDIda+jSgP0xfuSpW/NEJGXE=";
    serverEndpoint = "195.58.123.102";
    serverPort = 51820;
    listenPort = 51820;
    dns = [ "10.43.0.14" ];
    # Direct host-to-host link to rpi5-8gb over the gigabit LAN. Its prefixes
    # are more specific than (10.6.0.3/32) or disjoint from (10.42/10.43) the
    # router peer's 10.6.0.0/24, so they win and skip the router.
    extraPeers = [
      {
        publicKey = "NmlbH35CycjE1thGKwfU4pbYDCevMg+ui+jr9PiK9UM=";
        endpoint = "192.168.50.80:51820";
        allowedIPs = [
          "10.6.0.3/32"
          "10.42.0.0/24"
          "10.43.0.0/24"
        ];
        persistentKeepalive = 25;
      }
    ];
  };

  profiles = {
    smarthome = {
      enable = true;
    };

    auth = {
      enable = true;
      domain = "authentik.adama.lan";
    };

    monitoring = {
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
  };

  services = {
    authentik = {
      environmentFile = config.age.secrets.authentik-env.path;

      blueprints = [
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
    };
    prometheus = {
      enable = true;
      # scrapeConfigs = [
      #   {
      #     job_name = "starbuck";
      #     static_configs = [ { targets = [ "starbuck:9090" ]; } ];
      #   }
      #   {
      #     job_name = "openwrt";
      #     static_configs = [
      #       {
      #         targets = [
      #           "192.168.1.1:9100"
      #           "192.168.1.2:9100"
      #         ];
      #       }
      #     ];
      #   }
      # ];
    };

    cockpit = {
      enable = false;
      openFirewall = true;
      port = 8085;
    };
  };
}
