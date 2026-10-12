{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.profiles.smarthome;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.profiles.smarthome = {
    enable = mkEnableOption "Enable monitoring";
  };
  config = mkIf cfg.enable {
    systemd.services = {
      node-red.environment.NODE_PATH =
        "${pkgs.nodePackages.passport-openidconnect}/lib/node_modules";
      # Kanidm OIDC client secret for Node-RED's admin login (settings.js reads
      # this path at startup).
      node-red.environment.NODE_RED_OIDC_SECRET_FILE =
        config.age.secrets.node-red-oidc-secret.path;
      zigbee2mqtt.environment.Z2M_WATCHDOG = "default";
      zigbee2mqtt.serviceConfig.SystemCallFilter = lib.mkForce [ ];
    };

    networking.firewall.enable = false;

    networking.extraHosts = ''
      192.168.50.43 node-red.adama.lan
      192.168.50.43 home-assistant.adama.lan
      192.168.50.43 zigbee2mqtt.adama.lan
    '';

    services = {
      # MQTT now lives on the mosquitto workload (mosquitto.int.esselius.dev);
      # adama runs no local broker. See github.com/esselius/nix-workloads.
      mosquitto.enable = false;

      zigbee2mqtt = {
        enable = true;
        settings = {
          frontend.port = 8099;
          homeassistant = true;
          mqtt = {
            server = "mqtt://mosquitto.int.esselius.dev:1883";
            user = "z2m";
            password = "!" + config.age.secrets.z2m.path + " mqtt_password";
          };
          serial.adapter = "ember";
          advanced = {
            pan_id = 56089;
            ext_pan_id = [
              154
              147
              150
              234
              96
              16
              140
              189
            ];
            network_key = "!" + config.age.secrets.z2m.path + " network_key";
            channel = 11;
            last_seen = "ISO_8601";
            log_level = "warning";
            legacy_availability_payload = false;
          };
          availability = true;
        };
      };

      node-red = {
        enable = true;
        withNpmAndGcc = true;
        configFile = ./nodered-settings.js;
      };

      # SSO for the zigbee2mqtt frontend (replaces the Authentik outpost).
      # Runs as a reverse proxy in front of the z2m frontend.
      oauth2-proxy = {
        enable = true;
        provider = "oidc";
        oidcIssuerUrl = "https://idm.int.esselius.dev/oauth2/openid/oauth2-proxy";
        clientID = "oauth2-proxy";
        email.domains = [ "*" ];
        redirectURL = "https://zigbee2mqtt.adama.lan/oauth2/callback";
        upstream = [ "http://127.0.0.1:8099" ];
        reverseProxy = true;
        setXauthrequest = true;
        # Kanidm enforces PKCE; send an S256 challenge.
        extraConfig.code-challenge-method = "S256";
        # Client + cookie secrets are supplied via the agenix EnvironmentFile.
        keyFile = config.age.secrets.oauth2-proxy-env.path;
      };

      # TODO Run hass after postgres has started
      home-assistant = {
        enable = true;
        customComponents = [
          pkgs.audi_connect_ha
          pkgs.easee_hass
        ];
        extraComponents = [
          "zha"
          "google_translate"
          "mqtt"
          "cast"
          "homekit"
          "homekit_controller"
          "webostv"
          "apple_tv"
          "prometheus"
          "caldav"
          "plex"
          "spotify"
          "recorder"
          "history"
          "energy"
          "logbook"
          "oralb"
          "zeroconf"
          "switchbot"
          "ibeacon"
          "dlna_dmr"
          "icloud"
        ];
        config = {
          default_config = { };
          http = {
            use_x_forwarded_for = true;
            trusted_proxies = [ "127.0.0.1" ];
          };
          recorder.db_url = "postgresql://@/hass";
          prometheus.requires_auth = false;
        };
        extraPackages =
          p: with p; [
            # Recorder -> postgres
            psycopg2
            getmac
            kegtron-ble
            python-roborock
          ];
      };
      postgresql = {
        enable = true;
        ensureDatabases = [ "hass" ];
        ensureUsers = [
          {
            name = "hass";
            ensureDBOwnership = true;
          }
          {
            name = "pgadmin";
          }
        ];
      };

      nginx.virtualHosts = {
        "zigbee2mqtt.adama.lan" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            # Everything goes through oauth2-proxy, which serves /oauth2/* itself
            # and reverse-proxies the rest to the z2m frontend. Don't set Host /
            # X-Forwarded-* here - the module already includes the recommended
            # proxy headers, and duplicating them makes Go (oauth2-proxy) reject
            # the request with 400 (two Host headers).
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:4180";
          };
        };

        "node-red.adama.lan" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:${toString config.services.node-red.port}";
          };
        };

        "home-assistant.adama.lan" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:8123";
          };
        };
      };

    };
  };
}
