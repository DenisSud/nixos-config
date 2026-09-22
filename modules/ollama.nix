{ pkgs, ... }:

{
  # ── Ollama — local LLM server (CUDA), LAN-exposed ───────
  # API: http://pc:11434 (OpenAI-compatible at /v1)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "0.0.0.0";
    openFirewall = true; # LAN access
  };
}
