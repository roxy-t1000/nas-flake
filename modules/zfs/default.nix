{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ── Kernel / boot ────────────────────────────────────────────────────────────
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  # ── ARC size ─────────────────────────────────────────────────────────────────
  # By default ZFS will use up to half of RAM for ARC. On a dedicated NAS this
  # is usually fine, but cap it if you're running other services that need RAM.
  # Values are in bytes. Uncomment and adjust if needed.
  #
  # boot.kernelParams = [
  #   "zfs.zfs_arc_max=${toString (8 * 1024 * 1024 * 1024)}" # 8GB cap
  # ];

  # ── Maintenance ──────────────────────────────────────────────────────────────
  services.zfs = {
    # Scrub all pools monthly. ZFS reads every block and verifies checksums;
    # catches silent corruption early and triggers resilver if needed.
    autoScrub = {
      enable = true;
      interval = "monthly";
    };

    # TRIM for SSDs/NVMe (boot and data pools). Safe to leave enabled;
    # has no effect on HDDs.
    trim.enable = true;
  };

  # ── Snapshots ────────────────────────────────────────────────────────────────
  # Sanoid manages automatic ZFS snapshots with configurable retention.
  # Datasets with com.sun:auto-snapshot=false (set in disko) are skipped,
  # so only explicitly listed datasets below get snapshots.
  services.sanoid = {
    enable = true;
    templates = {
      # Frequently-changing data: keep fine-grained short-term, less long-term.
      frequent = {
        hourly = 24;
        daily = 14;
        monthly = 3;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
      # Bulk storage: daily snapshots, longer retention.
      bulk = {
        hourly = 0;
        daily = 30;
        monthly = 6;
        yearly = 1;
        autosnap = true;
        autoprune = true;
      };
    };
    datasets = {
      "boot/home" = {
        use_template = [ "frequent" ];
      };
      "boot/var" = {
        use_template = [ "frequent" ];
      };
      "data/databases" = {
        use_template = [ "frequent" ];
      };
      "bulk/media" = {
        use_template = [ "bulk" ];
      };
      "bulk/pictures" = {
        use_template = [ "bulk" ];
      };
      "bulk/backups" = {
        use_template = [ "bulk" ];
      };
      # downloads datasets intentionally omitted — transient data, not worth snapshotting.
    };
  };
}
