{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.denis.minecraft;
in
{
  # ── Minecraft Java server (Paper) ─────────────────────
  # Runs as the `minecraft` system user via systemd, world data in
  # /var/lib/minecraft, logs in the journal. Declarative: server.properties
  # is generated from this file on every start, so port/MOTD/online-mode are
  # changed here and take effect on restart, never by hand.
  options.denis.minecraft = {
    enable = lib.mkEnableOption "the Minecraft Java server (Paper, systemd-managed)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
      description = "TCP + UDP port the server listens on.";
    };

    memory = lib.mkOption {
      type = lib.types.str;
      default = "4G";
      example = "8G";
      description = "JVM heap, passed as both -Xms and -Xmx.";
    };

    motd = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Line shown in the client's server list.";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8;
      description = "max-players in server.properties.";
    };

    onlineMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Check players against Mojang's session servers. Set to false when the
        clients use offline accounts (TLauncher, Prism's "Offline" account):
        anyone who can reach the port then joins under any name, so keep it
        behind a VPN instead of a public port forward.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open `port` in the NixOS firewall.";
    };

    whitelist = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { denis = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; };
      description = ''
        Usernames mapped to Minecraft UUIDs, written to whitelist.json. Only
        takes effect with `serverProperties.white-list = true`. Offline
        accounts have derived UUIDs, so for those leave this empty and add
        players in-game with /whitelist add instead.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true; # the module refuses to start without it

      # Paper is a drop-in for the vanilla jar and exposes the same
      # bin/minecraft-server entrypoint the module expects. It bundles its
      # own headless JRE, so nothing is added to the system java.
      package = pkgs.papermc;

      dataDir = "/var/lib/minecraft";
      inherit (cfg) openFirewall whitelist;
      declarative = true;

      jvmOpts = "-Xms${cfg.memory} -Xmx${cfg.memory} -XX:+UseG1GC";

      serverProperties = {
        server-port = cfg.port;
        motd = cfg.motd;
        max-players = cfg.maxPlayers;
        online-mode = cfg.onlineMode;
        # 1.19+ drops clients that send no chat signature; Paper refuses to
        # boot with a secure profile required while online-mode is off.
        enforce-secure-profile = false;

        difficulty = "normal";
        gamemode = "survival";
        view-distance = 10;
        simulation-distance = 8;
        spawn-protection = 0;
        white-list = false;
      };
    };
  };
}
