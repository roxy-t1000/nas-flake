{ config, ... }:
let
  wan0 = "enp3s0";
  lan0 = "enp4s0";
in
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  networking = {
    nat = {
      enable = true;
      externalInterface = wan0;
      internalInterfaces = [ lan0 ];
    };
    interfaces = {
      ${wan0}.useDHCP = true;
      ${lan0} = {
        ipv4.addresses = [
          {
            address = "192.168.2.1";
            prefixLength = 24;
          }
        ];
      };
      dhcpd.denyInterfaces = [ lan0 ];
    };
  };
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      interface = lan0;
      dhcp-range = "192.168.2.2,192.168.2.200,24h"; # leaves space for microcloud addressing
      dhcp-option = [
        "option:router,192.168.2.1"
        "option:dns,192.168.2.1"
      ];
      dhcp-host = [
        # microk8s nodes
        "02:26:26:02:2d:bc,burly-bakiribu,192.168.2.12"
        "02:26:26:02:2d:e8,cool-cryodrakon,192.168.2.11"
        "02:26:26:02:2d:7f,darling-darwinopterus,192.168.2.10"

        # microcloud nodes
        "02:26:26:02:2c:a9,anxious-ankylosaurus,192.168.2.20"
        "02:26:26:02:16:f7,bubbly-baryonyx,192.168.2.21"
        "02:26:26:02:2b:7d,cranky-carnotaurus,192.168.2.22"
        "02:26:26:02:16:b0,dapper-deinonychus,192.168.2.23"
        "02:26:26:02:2c:c2,fluffy-fruitadens,192.168.2.25"
      ];
      domain-needed = true;
      bogus-priv = true;
    };
  };
  networking.firewall.interfaces.${lan0} = {
    allowedUDPPorts = [
      53
      67
    ];
    allowedTCPPorts = [ 53 ];
  };
}
