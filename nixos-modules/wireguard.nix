{ lib, config, pkgs, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types optional optionalString concatMapStrings;
  cfg = config.wireguard-vpn;
in
{
  options.wireguard-vpn = {
    enable = mkEnableOption "a WireGuard client interface to the router VPN";

    address = mkOption {
      type = types.str;
      example = "10.6.0.5/32";
      description = "This host's address inside the VPN subnet.";
    };

    privateKeySecret = mkOption {
      type = types.str;
      default = "wg-private-key";
      description = "agenix secret holding this host's base64 WireGuard private key.";
    };

    serverPublicKey = mkOption {
      type = types.str;
      description = "Public key of the router's WireGuard server (the only peer).";
    };

    serverEndpoint = mkOption {
      type = types.str;
      example = "195.58.123.102";
      description = "Hostname or IP the router's WireGuard server is reachable at.";
    };

    serverPort = mkOption {
      type = types.port;
      default = 51820;
    };

    listenPort = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 51820;
      description = ''
        Fixed UDP port for wg0 to listen on. Required for other hosts to dial
        this node directly (e.g. a host-to-host peer over the LAN). Leave null
        to let WireGuard pick a random port.
      '';
    };

    vpnSubnet = mkOption {
      type = types.str;
      default = "10.6.0.0/24";
      description = ''
        VPN subnet. Becomes part of the peer's AllowedIPs and the routes added
        via wg0, so the host can reach other VPN clients and return their
        traffic. Deliberately not 0.0.0.0/0 (split tunnel).
      '';
    };

    extraAllowedIPs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "10.43.0.0/24" ];
      description = ''
        Additional subnets routed into the tunnel, e.g. the incus VPN bridges
        on the Pi hosts so local processes can reach those instances.
      '';
    };

    dns = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "10.43.0.14" ];
      description = ''
        Nameservers to use while the tunnel is up, applied to `wg0` via
        resolvconf (prepended, so they take priority over DHCP). Empty means
        leave DNS untouched.
      '';
    };

    extraPeers = mkOption {
      type = types.listOf (types.submodule {
        options = {
          publicKey = mkOption { type = types.str; };
          endpoint = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          allowedIPs = mkOption { type = types.listOf types.str; };
          persistentKeepalive = mkOption {
            type = types.nullOr types.int;
            default = null;
          };
        };
      });
      default = [ ];
      description = ''
        Extra WireGuard peers, e.g. a direct host-to-host link to another VPN
        node so its prefixes stop hairpinning through the router. Their
        AllowedIPs must be disjoint from (or more specific than) the router
        peer's, otherwise the route is ambiguous.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking = {
      wireguard.interfaces.wg0 = {
        inherit (cfg) listenPort;
        ips = [ cfg.address ];
        privateKeyFile = config.age.secrets.${cfg.privateKeySecret}.path;
        # Add the peer's AllowedIPs as routes; without this the host can reach the
        # router but not the rest of the VPN subnet or the extra subnets.
        allowedIPsAsRoutes = true;
        peers = [
          {
            publicKey = cfg.serverPublicKey;
            endpoint = "${cfg.serverEndpoint}:${toString cfg.serverPort}";
            allowedIPs = [ cfg.vpnSubnet ] ++ cfg.extraAllowedIPs;
            # Keep the NAT mapping on the router alive so the server can always
            # push packets back to this host behind its home NAT.
            persistentKeepalive = 25;
          }
        ] ++ cfg.extraPeers;

        # Wire DNS through resolvconf (these hosts use openresolv, not resolved):
        # the nameservers are added for the lifetime of wg0 with metric 0 so they
        # win over the DHCP-provided resolvers.
        postSetup = optionalString (cfg.dns != [ ]) ''
          printf '${concatMapStrings (s: "nameserver ${s}\n") cfg.dns}' | ${pkgs.openresolv}/bin/resolvconf -a wg0 -m 0
        '';
        postShutdown = optionalString (cfg.dns != [ ]) ''
          ${pkgs.openresolv}/bin/resolvconf -d wg0
        '';
      };

      # Trust wg0 so VPN clients can reach this host's services without each port
      # being individually listed for the tunnel interface.
      firewall.trustedInterfaces = [ "wg0" ];

      # Accept the handshakes of hosts that dial this node directly.
      firewall.allowedUDPPorts = optional (cfg.listenPort != null) cfg.listenPort;
    };
  };
}
