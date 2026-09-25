{config, pkgs, ...}:
{
  services.prometheus.exporters = {
    dnsmasq = {
      enable = true;
      openFirewall = true; # to allow 192.168.2.0/24 access
    };
    smartctl = {
      enable = true;
      openFirewall = true;
    };
    zfs = {
      enable = true;
      openFirewall = true;
    };
    node = {
      enable = true;
      openFirewall = true;
    };
    blackbox = {
      enable = true;
      openFirewall = true;
      configFile = pkgs.writeText "blackbox.yaml" (builtins.toJSON {
        modules = {
          icmp_ping = {
            prober = "icmp";
            timeout = "3s";
          };
          dns_google = {
            prober = "dns";
            timeout = "2s";
            dns = {
              transport_protocol = "udp";
              preferred_ip_protocol = "ip4";
              query_name = "google.com";
              query_type = "A";
            };
          };
        };
      });
    };
  };
}
