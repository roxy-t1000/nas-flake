# secrets/secrets.nix
#
# This file declares which age public keys can decrypt each secret.
# Managed with: nix run .#agenix -- -e secrets/<file>.age
#
# To get the NAS host key after first boot:
#   ssh-keyscan nas.blenny-bramble.ts.net
# or directly: cat /etc/ssh/ssh_host_ed25519_key.pub
#
# Workflow:
#   1. Add your user public key and the NAS host public key below.
#   2. Run `nix run .#agenix -- -e secrets/tailscale-authkey.age`
#   3. Paste your Tailscale auth key, save and quit.
#   4. Commit the .age file; the plaintext never touches disk.

let
  # Your personal SSH key (for editing secrets from your workstation).
  jacob = "ssh-ed25519 AAAA_CHANGE_ME your-key-comment";

  # NAS host key — fill in after first boot.
  nas   = "ssh-ed25519 AAAA_CHANGE_ME_NAS_HOST_KEY root@nas";

  allKeys = [ jacob nas ];
in
{
  "tailscale-authkey.age".publicKeys = allKeys;
}
