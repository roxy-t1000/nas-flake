{ config, pkgs, ... }:

{
  imports = [
    # ./qbittorrent.nix # migrated to *arr stack lxc container
    # ./sabnzbd.nix # like above
    ./prometheus.nix
  ];
}
