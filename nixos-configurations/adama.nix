{ ... }:

{
  imports = [
    ../nixos-modules/sshd.nix
    ../nixos-modules/user-peteresselius.nix
    ../nixos-modules/ca.nix
    ../nixos-modules/nginx.nix
    ../nixos-modules/nix-gc.nix
    ../nixos-modules/hardware-rpi5.nix
    ../nixos-modules/wireguard.nix
    ../nixos-modules/monitoring-agent.nix
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
    wg-private-key.rekeyFile = ../secrets/wg-private-key.adama.age;
    z2m = {
      name = "z2m.yaml";
      rekeyFile = ../secrets/z2m.age;
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
    };
    node-red-oidc-secret = {
      rekeyFile = ../secrets/node-red-oidc-secret.age;
      owner = "node-red";
      group = "node-red";
    };
    oauth2-proxy-env = {
      rekeyFile = ../secrets/oauth2-proxy-env.age;
      owner = "oauth2-proxy";
      group = "oauth2-proxy";
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
  };

  services = {
    cockpit = {
      enable = false;
      openFirewall = true;
      port = 8085;
    };
  };
}
