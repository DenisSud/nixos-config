{ pkgs, ... }:

{
  # ── Ollama — local LLM server, CUDA build, LAN-exposed ─
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.ollama-cuda;
    openFirewall = true; # opens port 11434
  };
}
