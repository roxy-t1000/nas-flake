# NAS flake

NixOS configuration for a ZFS-based NAS with qBittorrent, SABnzbd, and Tailscale.

## Directory layout

```
.
├── flake.nix
├── hosts/
│   └── nas/
│       ├── default.nix       # Top-level host config (hostname, users, SSH)
│       ├── hardware.nix      # Boot loader, kernel modules, SMART
│       └── disko.nix         # Declarative disk/pool/dataset layout
├── modules/
│   ├── zfs/
│   │   └── default.nix       # ZFS tuning, scrub, TRIM, Sanoid snapshots
│   ├── networking/
│   │   ├── default.nix       # Tailscale + firewall
│   │   └── nfs.nix           # NFS exports for k8s cluster
│   └── services/
│       ├── default.nix
│       ├── qbittorrent.nix   # qBittorrent-nox systemd service
│       └── sabnzbd.nix       # SABnzbd systemd service
└── secrets/
    ├── secrets.nix            # agenix public key declarations
    └── tailscale-authkey.age  # encrypted Tailscale auth key (git-safe)
```

## Pre-install checklist

1. **Fill in disk IDs** in `hosts/nas/disko.nix`:
   ```bash
   ls -la /dev/disk/by-id/ | grep -v part
   ```

2. **Verify ashift** — wrong value is permanent and unrecoverable:
   ```bash
   # NVMe:
   nvme id-ns /dev/nvme0n1 | grep "LBA Format"
   # HDDs:
   hdparm -I /dev/sda | grep "Sector size"
   # Physical 4096B → ashift = "12" (already set). Genuine 512B → "9".
   ```

3. **Get the hostid** and put it in `hosts/nas/default.nix`:
   ```bash
   hostid
   ```

4. **Add your SSH public key** in `hosts/nas/default.nix` under
   `users.users.<username>.openssh.authorizedKeys.keys`.

5. **Add your personal public key** to `secrets/secrets.nix`.

6. **Encrypt the Tailscale auth key**:
   ```bash
   nix run .#agenix -- -e secrets/tailscale-authkey.age
   ```
   *(The NAS host key entry in secrets.nix can be filled in after first boot.)*

## Installation

Boot the NixOS installer ISO, then:

```bash
# From the installer, with the repo cloned or on a USB:
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko -- \
  --mode disko \
  /path/to/nas-flake/hosts/nas/disko.nix

sudo nixos-install --flake /path/to/nas-flake#nas
```

After reboot:

1. Grab the host SSH key: `cat /etc/ssh/ssh_host_ed25519_key.pub`
2. Add it to `secrets/secrets.nix` under `nas`.
3. Re-encrypt the authkey secret so the host can decrypt it:
   ```bash
   nix run .#agenix -- -e secrets/tailscale-authkey.age
   ```
4. `nixos-rebuild switch --flake .#nas`

## ZFS pool layout

| Pool   | Vdev     | Drives              | Use                            |
|--------|----------|---------------------|--------------------------------|
| `boot` | mirror   | 2× 1TB NVMe         | OS, /nix, /home, /var          |
| `data` | mirror   | 2× 1TB SSD          | Incomplete downloads, databases|
| `bulk` | raidz2   | 6× 8TB HDD          | Finished downloads, media, backups |

Usable bulk capacity: ~32TB (6×8 minus 2 parity drives).

## Connecting the *arr stack

The NAS exports paths over NFS on the Tailscale CGNAT range (`100.64.0.0/10`).

Mount from a k8s node or add a `PersistentVolume`:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nas-media
spec:
  capacity:
    storage: 20Ti
  accessModes: [ReadOnlyMany]
  nfs:
    server: nas.blenny-bramble.ts.net
    path: /bulk/media
  mountOptions: [hard, nfsvers=4.2]
```

Download clients (qBittorrent on `:8080`, SABnzbd on `:8090`) are reachable
over Tailscale. Point Sonarr/Radarr at:
- Download client host: `nas.blenny-bramble.ts.net`
- Remote path mapping: NAS `/bulk/downloads` ↔ k8s pod's NFS mount path
