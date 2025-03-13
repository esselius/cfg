{ inputs, config, lib, pkgs, ... }:

let
  cfg = config.profiles.smarthome;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.profiles.smarthome = {
    enable = mkEnableOption "Enable monitoring";
  };
  config = mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      listeners = [{
        acl = [ "pattern readwrite #" ];
        users.p1ib.password = "passw0rd";
        users.z2m.password = "passw0rd";
        users.hass.password = "passw0rd";
        users.nr.password = "passw0rd";
      }];
    };

    services.nginx.virtualHosts."zigbee2mqtt.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.zigbee2mqtt.settings.frontend.port}";
        extraConfig = ''
          auth_request     /outpost.goauthentik.io/auth/nginx;
          error_page       401 = @goauthentik_proxy_signin;
          auth_request_set $auth_cookie $upstream_http_set_cookie;
          add_header       Set-Cookie $auth_cookie;
        '';
      };
      locations."/outpost.goauthentik.io" = {
        proxyPass = "http://127.0.0.1:9000/outpost.goauthentik.io";
        extraConfig = ''
          proxy_set_header        X-Original-URL $scheme://$http_host$request_uri;
          add_header              Set-Cookie $auth_cookie;
          auth_request_set        $auth_cookie $upstream_http_set_cookie;
          proxy_pass_request_body off;
          proxy_set_header        Content-Length "";
        '';
      };
      locations."@goauthentik_proxy_signin" = {
        return = "302 /outpost.goauthentik.io/start?rd=$request_uri";
        extraConfig = ''
          internal;
          add_header Set-Cookie $auth_cookie;
        '';
      };
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        frontend.port = 8099;
        homeassistant = true;
        mqtt = {
          server = "mqtt://adama:1883";
          user = "z2m";
          password = "passw0rd";
        };
        serial.adapter = "ember";
        advanced = {
          pan_id = 56089;
          ext_pan_id = [ 154 147 150 234 96 16 140 189 ];
          network_key = "!" + config.age.secrets.z2m.path + " network_key";
          channel = 11;
          last_seen = "ISO_8601";
          log_level = "warning";
          legacy_availability_payload = false;
        };
        availability = true;
      };
    };

    services.nginx.virtualHosts."node-red.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.node-red.port}";
      };
    };

    services.node-red = {
      enable = true;
      withNpmAndGcc = true;
      configFile = ./nodered-settings.js;
    };
    systemd.services.node-red.environment.NODE_PATH =
      "${pkgs.nodePackages.passport-openidconnect}/lib/node_modules";

    services.nginx.virtualHosts."home-assistant.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:8123";
      };
    };

    # TODO Run hass after postgres has started
    services.home-assistant = {
      enable = true;
      customComponents = [
        pkgs.audi_connect_ha
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
      extraPackages = p: with p; [
        # Recorder -> postgres
        psycopg2
        getmac
      ];
    };
    services.prometheus.scrapeConfigs = [{
      job_name = "home-assistant";
      metrics_path = "/api/prometheus";
      static_configs = [{
        targets = [ "127.0.0.1:${toString config.services.home-assistant.config.http.server_port}" ];
      }];
    }];
    networking.firewall.enable = false;
    services.postgresql = {
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

    services.nginx.virtualHosts."pgadmin.adama.lan" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${toString config.services.pgadmin.port}";
      };
    };

    services.pgadmin = {
      enable = false;
      settings = {
        AUTHENTICATION_SOURCES = [ "oauth2" ];
        OAUTH2_CONFIG = [{
          OAUTH2_NAME = "authentik";
          OAUTH2_DISPLAY_NAME = "Authentik";
          OAUTH2_CLIENT_ID = "pgadmin";
          OAUTH2_CLIENT_SECRET = "secret";
          OAUTH2_TOKEN_URL = "https://authentik.adama.lan/application/o/token/";
          OAUTH2_AUTHORIZATION_URL = "https://authentik.adama.lan/application/o/authorize/";
          OAUTH2_USERINFO_ENDPOINT = "https://authentik.adama.lan/application/o/userinfo/";
          OAUTH2_SCOPE = "openid email profile";
          OAUTH2_API_BASE_URL = "https://authentik.adama.lan/";
          OAUTH2_SSL_CERT_VERIFICATION = false;
          OAUTH2_SERVER_METADATA_URL = "https://authentik.adama.lan/application/o/pgadmin/.well-known/openid-configuration";
        }];
      };
      initialEmail = "pepp@me.com";
      initialPasswordFile = builtins.toFile "pgadmin-pass" "password";
    };
  };
}
