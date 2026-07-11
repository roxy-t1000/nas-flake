{ config, pkgs, lib, ... }:

# qBittorrent-nox (headless) managed as a systemd service.
# The Web UI is reachable at http://nas.blenny-bramble.ts.net:8080
# (only over Tailscale — firewall blocks it on LAN interfaces).
#
# First-run: qbittorrent generates a random password and logs it to the journal.
#   journalctl -u qbittorrent -n 50 | grep "password"
# Then configure in the Web UI:
#   Tools → Options → Downloads:
#     Default save path:           /bulk/downloads
#     Keep incomplete torrents in: /data/downloads-incomplete

{
  # Run as its own user for isolation.
  users.users.qbittorrent = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/qbittorrent";
    createHome = true;
  };
  users.groups.media = {};

  # The arr stack services on k8s will need to write to /bulk/media and read
  # /bulk/downloads. Export these over NFS (see nfs.nix) and ensure the UID/GID
  # used inside your k8s pods matches the `media` group here, or use
  # no_root_squash on the NFS export.

  systemd.services.qbittorrent = {
    description = "qBittorrent-nox";
    after    = [ "network-online.target" "zfs.target" ];
    wants    = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type            = "simple";
      User            = "qbittorrent";
      Group           = "media";
      ExecStart       = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      Restart         = "on-failure";
      RestartSec      = "5s";

      # State directory under /var/lib/qbittorrent
      StateDirectory  = "qbittorrent";

      # Hardening
      PrivateTmp           = true;
      ProtectSystem        = "strict";
      ReadWritePaths       = [
        "/data/downloads-incomplete"
        "/bulk/downloads"
        "/bulk/media"
      ];
      NoNewPrivileges      = true;
    };

    environment = {
      QBT_PROFILE = "/var/lib/qbittorrent";
      # Web UI port; change if you want something other than 8080.
      QBT_WEBUI_PORT = "8080";
    };
  };

  # Only reachable via Tailscale (tailscale0 is a trusted interface).
  networking.firewall.allowedTCPPorts = lib.mkIf false [ 8080 ];
  # ^ intentionally disabled for LAN. Tailscale handles access.
}
