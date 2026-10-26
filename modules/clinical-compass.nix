{
  pkgs,
  ...
}:

let
  appDir = "/home/denis/apps/clinical-compass";
in
{
  # ── Clinical Compass: demo stand ──────────────────────────────────────
  # The championship build, not a dev server: Caddy on pi terminates TLS for
  # compas.sudakov.site and proxies here over the LAN, so the process binds
  # 0.0.0.0 and never sees the internet directly.
  #
  # Code and node_modules live outside the store because the app needs a
  # writable SQLite file and `npm ci` per deploy; `nixos-rebuild` only owns
  # the unit. Update the app with scripts/deploy.sh from the repo.
  systemd.services.clinical-compass = {
    description = "Clinical Compass demo (patient + doctor)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      NODE_ENV = "production";
      PORT = "8110";
      HOST = "0.0.0.0";
      SQLITE_DB = "${appDir}/var/demo.db";
    };

    # tsx starts with `#!/usr/bin/env node`, and system units do not inherit
    # the system profile, so node must come in through `path`.
    path = [ pkgs.nodejs_24 ];

    serviceConfig = {
      Type = "simple";
      User = "denis";
      Group = "users";
      WorkingDirectory = appDir;
      ExecStart = "${appDir}/node_modules/.bin/tsx server/index.ts";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
