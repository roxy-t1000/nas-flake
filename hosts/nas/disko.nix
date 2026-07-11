# hosts/nas/disko.nix
#
# Disk IDs: fill these in before running disko.
# Find them with: ls -la /dev/disk/by-id/ | grep -v part
#
# IMPORTANT: verify ashift before creating pools.
#   NVMe:  nvme id-ns /dev/nvme0n1 | grep "LBA Format"
#   HDDs:  hdparm -I /dev/sda | grep "Sector size"
# If physical sector size is 4096B, ashift = "12" (correct below).
# If genuinely 512B native (rare, older drives), use ashift = "9".

{ ... }:

let
  nvme0 = "/dev/disk/by-id/nvme-CHANGE_ME_0";
  nvme1 = "/dev/disk/by-id/nvme-CHANGE_ME_1";
  ssd0  = "/dev/disk/by-id/ata-CHANGE_ME_ssd0";
  ssd1  = "/dev/disk/by-id/ata-CHANGE_ME_ssd1";
  hdd0  = "/dev/disk/by-id/ata-CHANGE_ME_hdd0";
  hdd1  = "/dev/disk/by-id/ata-CHANGE_ME_hdd1";
  hdd2  = "/dev/disk/by-id/ata-CHANGE_ME_hdd2";
  hdd3  = "/dev/disk/by-id/ata-CHANGE_ME_hdd3";
  hdd4  = "/dev/disk/by-id/ata-CHANGE_ME_hdd4";
  hdd5  = "/dev/disk/by-id/ata-CHANGE_ME_hdd5";
in
{
  disko.devices = {

    # ── Disks ──────────────────────────────────────────────────────────────────

    disk.nvme0 = {
      type = "disk";
      device = nvme0;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              mountOptions = [ "umask=0077" ];
            };
          };
          zfs = {
            size = "100%";
            content = { type = "zfs"; pool = "boot"; };
          };
        };
      };
    };

    disk.nvme1 = {
      type = "disk";
      device = nvme1;
      content = {
        type = "gpt";
        partitions = {
          # Second ESP: not auto-mounted; copy manually for fallback boot.
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              # No mountpoint — managed manually as a mirror of the first ESP.
            };
          };
          zfs = {
            size = "100%";
            content = { type = "zfs"; pool = "boot"; };
          };
        };
      };
    };

    disk.ssd0 = {
      type = "disk";
      device = ssd0;
      content = {
        type = "gpt";
        partitions.zfs = {
          size = "100%";
          content = { type = "zfs"; pool = "data"; };
        };
      };
    };

    disk.ssd1 = {
      type = "disk";
      device = ssd1;
      content = {
        type = "gpt";
        partitions.zfs = {
          size = "100%";
          content = { type = "zfs"; pool = "data"; };
        };
      };
    };

    disk.hdd0 = { type = "disk"; device = hdd0; content = { type = "gpt"; partitions.zfs = { size = "100%"; content = { type = "zfs"; pool = "bulk"; }; }; }; };
    disk.hdd1 = { type = "disk"; device = hdd1; content = { type = "gpt"; partitions.zfs = { size = "100%"; content = { type = "zfs"; pool = "bulk"; }; }; }; };
    disk.hdd2 = { type = "disk"; device = hdd2; content = { type = "gpt"; partitions.zfs = { size = "100%"; content = { type = "zfs"; pool = "bulk"; }; }; }; };
    disk.hdd3 = { type = "disk"; device = hdd3; content = { type = "gpt"; partitions.zfs = { size = "100%"; content = { type = "zfs"; pool = "bulk"; }; }; }; };
    disk.hdd4 = { type = "disk"; device = hdd4; content = { type = "gpt"; partitions.zfs = { size = "100%"; content = { type = "zfs"; pool = "bulk"; }; }; }; };
    disk.hdd5 = { type = "disk"; device = hdd5; content = { type = "gpt"; partitions.zfs = { size = "100%"; content = { type = "zfs"; pool = "bulk"; }; }; }; };

    # ── Pools ──────────────────────────────────────────────────────────────────

    zpool.boot = {
      type = "zpool";
      mode = "mirror";
      options.ashift = "12";
      rootFsOptions = {
        compression    = "zstd";
        acltype        = "posixacl";
        xattr          = "sa";
        atime          = "off";
        mountpoint     = "none";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        nixos = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            mountpoint = "legacy";
            atime = "off";
          };
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
          options.mountpoint = "legacy";
        };
        var = {
          type = "zfs_fs";
          mountpoint = "/var";
          options.mountpoint = "legacy";
        };
      };
    };

    zpool.data = {
      type = "zpool";
      mode = "mirror";
      options.ashift = "12";
      rootFsOptions = {
        compression = "zstd";
        atime       = "off";
        mountpoint  = "none";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        # Incomplete downloads: high random I/O, default 128K recordsize is fine.
        downloads-incomplete = {
          type = "zfs_fs";
          mountpoint = "/data/downloads-incomplete";
          options.mountpoint = "legacy";
        };
        # Databases: match postgres/mariadb page size.
        databases = {
          type = "zfs_fs";
          mountpoint = "/data/databases";
          options = {
            mountpoint = "legacy";
            recordsize = "16K";
            # Sync writes are critical for DB integrity.
            # "disabled" would be faster but risks corruption on power loss.
            sync = "standard";
          };
        };
      };
    };

    zpool.bulk = {
      type = "zpool";
      # disko raidz2 via topology
      mode = {
        topology = {
          type = "topology";
          vdev = [{
            mode = "raidz2";
            members = [ "hdd0" "hdd1" "hdd2" "hdd3" "hdd4" "hdd5" ];
          }];
        };
      };
      options.ashift = "12";
      rootFsOptions = {
        compression = "zstd";
        atime       = "off";
        mountpoint  = "none";
        # Large sequential reads/writes — 1M recordsize is appropriate.
        recordsize  = "1M";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        # Finished downloads; arr stack moves files from here to media.
        # Both on bulk so the move is a cheap metadata rename within the pool.
        downloads = {
          type = "zfs_fs";
          mountpoint = "/bulk/downloads";
          options.mountpoint = "legacy";
        };
        media = {
          type = "zfs_fs";
          mountpoint = "/bulk/media";
          options.mountpoint = "legacy";
        };
        backups = {
          type = "zfs_fs";
          mountpoint = "/bulk/backups";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}
