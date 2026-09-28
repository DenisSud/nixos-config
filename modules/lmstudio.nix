{ pkgs, inputs, ... }:

let
  lm = inputs.lmstudio.packages.${pkgs.stdenv.hostPlatform.system};

  # llmster's HTTP server is a separate toggle inside the daemon, so flip it
  # on once the daemon answers (it takes a moment to come up).
  startServer = pkgs.writeShellScript "lmstudio-server-start" ''
    for _ in {1..30}; do
      ${lm.lmstudio-server}/bin/lms server start --port 1234 --bind 0.0.0.0 && exit 0
      ${pkgs.coreutils}/bin/sleep 1
    done
    exit 1
  '';
in
{
  # ── LM Studio — local LLM server (CUDA), LAN-exposed ─────
  # GUI + headless daemon share one home (~/.lmstudio), so models
  # downloaded in the GUI are immediately served over the API.
  # API: http://pc:1234 (OpenAI-compatible at /v1); manage with `lms`.
  users.users.denis = {
    linger = true; # daemon stays up without an active session
    packages = [ lm.default ]; # desktop app
  };

  systemd.user.services.lmstudio = {
    description = "LM Studio server (llmster)";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${lm.lmstudio-server}/bin/llmster";
      ExecStartPost = startServer;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking.firewall.allowedTCPPorts = [ 1234 ]; # firewall is off on pc; kept for when it returns
}
