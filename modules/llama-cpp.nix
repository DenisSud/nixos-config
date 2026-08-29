{ pkgs, ... }:

{
  # ── llama.cpp server — Qwen3.8-27B (UD-IQ2_XXS), CUDA, fully GPU-resident ─
  # Model (~7.3 GB) + q4_0 KV cache at 131k ctx (~2.2 GB, hybrid attention —
  # only 16/64 layers keep KV) + recurrent state + compute ≈ 11 GB VRAM.
  # First start downloads the GGUF to /var/cache/llama-cpp.
  # Web UI / OpenAI-compatible API: http://localhost:8080
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    openFirewall = false; # localhost only
    settings = {
      host = "127.0.0.1";
      port = 8080;

      hf-repo = "unsloth/Qwen3.8-27B-GGUF";
      hf-file = "Qwen3.8-27B-UD-IQ2_XXS.gguf";
      alias = "Qwen3.8-27B"; # stable model id exposed via /v1/models

      gpu-layers = 99; # all layers on GPU
      ctx-size = 131072;
      flash-attn = "on";
      cache-type-k = "q4_0";
      cache-type-v = "q4_0";
      no-mmproj = true; # skip vision encoder — saves ~0.9 GB VRAM
      threads = 12;
      batch-size = 2048;
      ubatch-size = 512;

      temp = "1.0"; # thinking-mode defaults per model card
      top-p = "0.95";
      top-k = "20";
    };
  };

  # Shader cache dir fix (nixpkgs issue #441531)
  systemd.services.llama-cpp.environment = {
    XDG_CACHE_HOME = "/var/cache/llama-cpp";
    MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
  };
}
