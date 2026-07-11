{ config, ... }:

# NFS exports for the Kubernetes cluster and MicroCloud nodes.
# Accessed via Tailscale IPs — no LAN exposure needed.
#
# On k8s, create a PersistentVolume per export, e.g.:
#
#   apiVersion: v1
#   kind: PersistentVolume
#   metadata:
#     name: nas-databases
#   spec:
#     capacity:
#       storage: 500Gi
#     accessModes: [ReadWriteMany]
#     nfs:
#       server: nas.blenny-bramble.ts.net
#       path: /data/databases
#     mountOptions: [hard, nfsvers=4.2]

{
  services.nfs.server = {
    enable = true;
    # NFSv4 only; no need for rpcbind/portmapper.
    exports = ''
      # Tailscale CGNAT range — covers all your tailnet nodes.
      # Tighten to specific IPs once you know them, e.g. 100.x.y.z/32.
      /data/databases  100.64.0.0/10(rw,sync,no_subtree_check,no_root_squash)
      /bulk/media      100.64.0.0/10(ro,sync,no_subtree_check)
      /bulk/backups    100.64.0.0/10(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  # NFSv4 only needs port 2049; rpcbind (111) not required.
  networking.firewall.allowedTCPPorts = [ 2049 ];
}
