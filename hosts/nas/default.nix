{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./disko.nix
    ../../modules/zfs
    ../../modules/networking
    ../../modules/services
  ];

  # ── Identity ────────────────────────────────────────────────────────────────
  networking.hostName = "nas";
  # Required by ZFS to prevent pool imports on multiple machines simultaneously.
  # Generate with: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' \n'
  networking.hostId = "00000000"; # CHANGE THIS before first boot

  # ── Locale / time ───────────────────────────────────────────────────────────
  time.timeZone = "America/New_York"; # adjust to your zone
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Users ───────────────────────────────────────────────────────────────────
  users.users.jacob = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      # "ssh-ed25519 AAAA..."
    ];
  };

  # ── Base packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    agenix   # secret management CLI
    htop
    lsof
    smartmontools
    hdparm
  ];

  # ── SSH ─────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "24.11";
}
