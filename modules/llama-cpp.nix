{ pkgs, lib, ... }:

{
  # ── llama.cpp server — Qwen3.8-27B (UD-IQ2_XXS), CUDA, fully GPU-resident ─
  # Model (~7.3 GB) + q4_0 KV cache at 131k ctx (~2.2 GB, hybrid attention —
  # only 16/64 layers keep KV) + recurrent state + compute ≈ 11 GB VRAM.
  # First start downloads the GGUF to /var/cache/llama-cpp.
  # Web UI / OpenAI-compatible API: http://<host>:8080 (LAN-exposed)
  # Port 8080: linkers-demo was moved off it.
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    openFirewall = true; # LAN access
    settings = {
      host = "0.0.0.0";
      port = 8080;

      hf-repo = "unsloth/Qwen3.8-27B-GGUF";
      hf-file = "Qwen3.8-27B-UD-IQ2_XXS.gguf";
      alias = "Qwen3.8-27B"; # stable model id exposed via /v1/models

      gpu-layers = 99; # all layers on GPU
      ctx-size = 65536;
      flash-attn = "on";
      cache-type-k = "q4_0";
      cache-type-v = "q4_0";
      # no-mmproj not set → vision encoder (mmproj) loaded, /v1/chat image input works
      threads = 12;
      batch-size = 2048;
      ubatch-size = 512;


      temp = "1.0"; # sampling defaults per model card
      top-p = "0.95";
      top-k = "20";
    };
  };

  # Do not auto-start; occupies ~11 GB VRAM. Start manually with
  #   sudo systemctl start llama-cpp
  systemd.services.llama-cpp.wantedBy = lib.mkForce [ ];

  # Qwen3.8 template default is xhigh reasoning — too much thinking. Set via env var:
  # the module writes settings verbatim into ExecStart and systemd strips quotes there.
  systemd.services.llama-cpp.environment.LLAMA_ARG_CHAT_TEMPLATE_KWARGS = ''{"reasoning_effort":"low"}'';

  # Shader cache dir fix (nixpkgs issue #441531)
  systemd.services.llama-cpp.environment = {
    XDG_CACHE_HOME = "/var/cache/llama-cpp";
    MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
  };
}
