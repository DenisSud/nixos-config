{ pkgs, ... }:

{
  # ── Ollama — local LLM server, CUDA build, localhost-only ─
  services.ollama = {
    enable = true;
    host = "127.0.0.1"; # localhost only — no LAN/web exposure
    package = pkgs.ollama-cuda;
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
      OLLAMA_CONTEXT_LENGTH = "65536";
    };
  };
}
