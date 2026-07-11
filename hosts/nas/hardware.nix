{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # ── Boot ────────────────────────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    # Mirror the ESP: after install, copy /boot/efi to the second NVMe's ESP
    # partition manually, then add it to your BIOS boot order as a fallback.
    # grub with mirroredBoots is the fully-automated alternative if you prefer.
    efi.efiSysMountPoint = "/boot/efi";
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ]; # swap for kvm-amd if applicable

  # ── Filesystems declared by disko ───────────────────────────────────────────
  # disko generates the fileSystems entries for ZFS datasets with
  # mountpoint = "legacy". Nothing extra needed here.

  # ── Hardware-specific tuning ─────────────────────────────────────────────────
  # Enable SMART monitoring on all drives
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.mail.enable = false; # flip to true and configure if desired
  };

  hardware.enableRedistributableFirmware = true;
}
