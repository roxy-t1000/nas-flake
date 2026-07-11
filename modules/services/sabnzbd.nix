{ config, pkgs, lib, ... }:

# SABnzbd (Usenet downloader), managed as a systemd service.
# Web UI at http://nas.blenny-bramble.ts.net:8090 (Tailscale only).
#
# On first run, SABnzbd generates a config at /var/lib/sabnzbd/sabnzbd.ini.
# Configure via Web UI:
#   Config → Folders:
#     Temporary Download Folder: /data/downloads-incomplete
#     Completed Download Folder: /bulk/downloads
#   Config → Servers: add your Usenet provider

{
  users.users.sabnzbd = {
    isSystemUser = true;
    group = "media";
    home = "/var/lib/sabnzbd";
    createHome = true;
  };
  # `media` group declared in qbittorrent.nix; reuse it here.

  systemd.services.sabnzbd = {
    description = "SABnzbd";
    after    = [ "network-online.target" "zfs.target" ];
    wants    = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type       = "simple";
      User       = "sabnzbd";
      Group      = "media";
      ExecStart  = "${pkgs.sabnzbd}/bin/sabnzbd --server 0.0.0.0:8090 --config-file /var/lib/sabnzbd/sabnzbd.ini --nodaemon";
      Restart    = "on-failure";
      RestartSec = "5s";

      StateDirectory = "sabnzbd";

      PrivateTmp      = true;
      ProtectSystem   = "strict";
      ReadWritePaths  = [
        "/data/downloads-incomplete"
        "/bulk/downloads"
        "/bulk/media"
        "/var/lib/sabnzbd"
      ];
      NoNewPrivileges = true;
    };
  };
}
