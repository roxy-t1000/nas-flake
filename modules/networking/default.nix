{ config, pkgs, ... }:

{
  imports = [
    ./dnsmasq.nix
    ./nfs.nix
    ./samba.nix
  ];

  # ── Firewall ─────────────────────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    # Trust Tailscale and the LAN interface (enp3s0), not the WAN interface.
    trustedInterfaces = [ "tailscale0" "enp3s0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # ── Tailscale ────────────────────────────────────────────────────────────────
  services.tailscale = {
    enable = true;
    # Auth key is written to this path by agenix at activation time.
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    # Advertise this machine as an exit node if desired; remove if not.
    extraUpFlags = [
      "--ssh" # enable Tailscale SSH as a fallback
    ];
  };

  # ── Secrets ──────────────────────────────────────────────────────────────────
  age.secrets.tailscale-authkey = {
    file = ../../secrets/tailscale-authkey.age;
    # Tailscale service runs as root, so default owner is fine.
  };
}
