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
  anderson = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMltYp0nSf+aRcpKo9hysa2kHTGOiguAMEVzpL6gMgHC quanchobi@github/104924783"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1ybz4VPgDcqpZWHICYx1kOJXDivZO+LkA5NSgrAb6m quanchobi@github/151238882"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwJx1/hCrFc4DjqmITdmggOf9pQhTHq3YgsRm/Pg+QbO4PPyySD2LgTzZKIYY50u2AkLUyJOzx8cL85eNI8jus1Smz7Kmb0gMUQmZroFsruaXMsIkiR01iA9nbTuyka7pDjJk8BiTUSUY96jl2M12JKSA7KLxCCBd8J/bBD4BxqRSz6fe5Kla7T7waxHaqNUv8+3kgGeo7MAjNmjvdkSp/w8FUhHaXARbAywOeOGn5e5vReDnTF2kxYAqx9lOXO40c/+ShThd8J9pfiNp3v082eEPf+gsRPSQFyGfk1AZ0i1fNSh25+H2FfnsRqbOpCTVPqT1vKSwHNmg58pe5Nf1FGFYZtLDvcKdXXt3/RZ/RS3MsiXoc72ttlK2l6uty5j3lvK4YrD2MKyCq++mHX7b6B/sRO59kpTIgLDVnhSflKBrhpT87MkgAl9MRiO9pp8+ez1wmghUREo+zQTF4iieOh9CEExdgnTmgpw7n8GEDN2O8vapjTw/LciwtnMi58o0= quanchobi@github/118126293"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3NjmpD/Xdn37n69KePC4Sdjc+1RotmGIk5mUXEdJIz quanchobi@github/143826786"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYuGbAyqysSfEU6ar8msEQSHOKr8Jbf4NadMQqkTKqS quanchobi@github/118826387"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+/WlC4szrAvPjG3tEE5dsbKi9uQ1oJxsmZ/PzMxTQX quanchobi@github/144126139"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIASQoj2af+NJf0jJ07sXtq3Vlze7mIbXRl9ygQpwMchD quanchobi@github/133457269"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC16UtJLGpXQJJc1tmgxRQQk81//joqSySs8dhGVszSF quanchobi@github/153779536"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzi7tDEaGJ1bgXzirp9LCbvEmD9w8RYCC5nzGOk3Uku quanchobi@github/148591142"
  ];

  # NAS host key — fill in after first boot.
  nas = "";

  allKeys = anderson ++ [ nas ];
in
{
  "tailscale-authkey.age".publicKeys = allKeys;
}
