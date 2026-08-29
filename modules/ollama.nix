{ pkgs, ... }:

{
  # ── Ollama — local LLM server, CPU-only build, LAN-exposed ─
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.ollama; # CPU-only (no CUDA acceleration)
    openFirewall = true; # opens port 11434
  };
}
