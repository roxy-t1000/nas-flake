{ config, ... }:
{
  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;

    settings = {
      global = {
        # Bind only to the Tailscale interface
        "interfaces" = "tailscale0";
        "bind interfaces only" = "yes";

        "workgroup" = "WORKGROUP";
        "server string" = "NAS";
        "server role" = "standalone server";

        "server min protocol" = "SMB2";
      };
      "media" = {
        path = "/bulk/media";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "write list" = "anderson";
      };
    };
  };
}
