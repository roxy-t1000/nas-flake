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
  networking.hostName = "sylphiette";
  # Required by ZFS to prevent pool imports on multiple machines simultaneously.
  networking.hostId = "8425e349";

  # ── Locale / time ───────────────────────────────────────────────────────────
  time.timeZone = "America/Kentucky/Monticello";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Users ───────────────────────────────────────────────────────────────────
  users.users.anderson = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMltYp0nSf+aRcpKo9hysa2kHTGOiguAMEVzpL6gMgHC quanchobi@github/104924783"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1ybz4VPgDcqpZWHICYx1kOJXDivZO+LkA5NSgrAb6m quanchobi@github/151238882"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwJx1/hCrFc4DjqmITdmggOf9pQhTHq3YgsRm/Pg+QbO4PPyySD2LgTzZKIYY50u2AkLUyJOzx8cL85eNI8jus1Smz7Kmb0gMUQmZroFsruaXMsIkiR01iA9nbTuyka7pDjJk8BiTUSUY96jl2M12JKSA7KLxCCBd8J/bBD4BxqRSz6fe5Kla7T7waxHaqNUv8+3kgGeo7MAjNmjvdkSp/w8FUhHaXARbAywOeOGn5e5vReDnTF2kxYAqx9lOXO40c/+ShThd8J9pfiNp3v082eEPf+gsRPSQFyGfk1AZ0i1fNSh25+H2FfnsRqbOpCTVPqT1vKSwHNmg58pe5Nf1FGFYZtLDvcKdXXt3/RZ/RS3MsiXoc72ttlK2l6uty5j3lvK4YrD2MKyCq++mHX7b6B/sRO59kpTIgLDVnhSflKBrhpT87MkgAl9MRiO9pp8+ez1wmghUREo+zQTF4iieOh9CEExdgnTmgpw7n8GEDN2O8vapjTw/LciwtnMi58o0= quanchobi@github/118126293"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIP8bFfS4NSrcgjICLeTZhkx1SEUArPQkgUbfO7nO1xHNAAAABHNzaDo= quanchobi@github/145760574"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3NjmpD/Xdn37n69KePC4Sdjc+1RotmGIk5mUXEdJIz quanchobi@github/143826786"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYuGbAyqysSfEU6ar8msEQSHOKr8Jbf4NadMQqkTKqS quanchobi@github/118826387"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILDJkm+0f5esZ6TJlN91ZfI22+7UrtpKS2HDqotAqSbBAAAABHNzaDo= quanchobi@github/150081371"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+/WlC4szrAvPjG3tEE5dsbKi9uQ1oJxsmZ/PzMxTQX quanchobi@github/144126139"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIASQoj2af+NJf0jJ07sXtq3Vlze7mIbXRl9ygQpwMchD quanchobi@github/133457269"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC16UtJLGpXQJJc1tmgxRQQk81//joqSySs8dhGVszSF quanchobi@github/153779536"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzi7tDEaGJ1bgXzirp9LCbvEmD9w8RYCC5nzGOk3Uku quanchobi@github/148591142"
    ];
  };

  # ── Nix settings ────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ── Base packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # agenix # secret management CLI
    btop
    lsof
    smartmontools
    hdparm
    vim
    git
    tmux
  ];

  # ── SSH ─────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "26.05";
}
