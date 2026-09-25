{
  config,
  pkgs,
  lib,
  ...
}:

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
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "unrar"
    ];
  services.sabnzbd.enable = true;
}
