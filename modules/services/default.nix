{ config, pkgs, ... }:

{
  imports = [
    ./qbittorrent.nix
    ./sabnzbd.nix
  ];
}
