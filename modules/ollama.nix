{ pkgs, ... }:

{
  # ── Ollama — local LLM server, CUDA build, LAN-exposed ─
  # (merged from g14: LAN exposure; from pc: CUDA build + tuned env)
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = pkgs.ollama-cuda;
    openFirewall = true; # opens port 11434
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
      OLLAMA_CONTEXT_LENGTH = "65536";
    };
  };
}
