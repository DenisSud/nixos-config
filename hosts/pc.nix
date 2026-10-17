{
  pkgs,
  ...
}:

{
  # ╔══════════════════════════════════════════════════════════╗
  # ║  PC — Desktop (AMD Ryzen + NVIDIA RTX 5070 / Blackwell)  ║
  # ╚══════════════════════════════════════════════════════════╝
  # Thin host: imports the shared layer and sets `denis.*` values.
  # Hardware-specific bits (NVIDIA, file systems) stay below.
  imports = [ ../modules/shared.nix ];

  # ── Host identity ─────────────────────────────────────
  denis.hostName = "pc";

  # ── Firewall: kept off on pc ─────────────────────────
  # Flipped off 2026-08-31 ("temporarily disabled") and never reverted.
  # Turning it on needs the LAN ports opened first, e.g. 8080 for the
  # linkers demo (systemd user service on this box).
  denis.firewall.enable = false;

  # ── Kernel / routing ──────────────────────────────────
  denis.latestKernel = true;
  denis.ipForward = true;

  # ── Feature toggles ───────────────────────────────────
  denis.docker.enable = true;
  denis.podman.enable = true;
  denis.gaming.enable = true;
  denis.xray.enable = true;
  denis.happ.enable = true;
  denis.wakeOnLan.enable = true;
  denis.wakeOnLan.ethernetInterface = "eno1";
  denis.tmux.enable = true;

  # ── PC-only user packages ─────────────────────────────
  denis.userPackages = with pkgs; [
    libreoffice
    # Unfree + FHS-wrapped; the installer is fetched from Blackmagic at
    # build time (~4 GB), so the first rebuild that includes it is slow.
    # GPU acceleration uses the NVIDIA driver's CUDA libs via
    # addDriverRunpath — nothing extra to configure here.
    davinci-resolve
    gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
  ];

  # ── NVIDIA (RTX 5070 / Blackwell, open kernel module) ─
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true; # needed for proper suspend/resume
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── Ollama (local LLM server, CUDA on the RTX 5070) ──
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "0.0.0.0";
  };

  # ── Phonon-2 dictation ASR (mason's web client) ────────
  # The OpenAI-compatible speech server the dictation button posts to:
  # POST http://<page host>:8000/v1/audio/transcriptions (multipart).
  # The model (~164 MB) is fetched from Hugging Face on first start and
  # kept in the phonon-cache volume. CPU-only; no GPU needed.
  # NOTE: bound to all interfaces — the unauthenticated endpoint is LAN-
  # exposed, same as ollama above (firewall is off on this host).
  virtualisation.oci-containers = {
    backend = "podman";
    containers.phonon = {
      image = "ghcr.io/fermionresearch/phonon-cpu:2.0.9";
      cmd = [
        "serve"
        "phonon-2"
        "--host"
        "0.0.0.0"
        "--cors"
      ];
      ports = [ "8000:8000" ];
      volumes = [ "phonon-cache:/home/phonon/.cache" ];
    };
  };

  # nvcc only generates device code for the 5070 (Blackwell, sm_120).
  # Without this, ollama-cuda builds llama.cpp for all 9 supported
  # architectures (sm_75 … sm_121), which is the bulk of the build time.
  # Note: the resulting binary targets sm_120 only — it would not run on
  # the g14's RTX 3050 (sm_86) if ollama were ever enabled there.
  nixpkgs.config.cudaCapabilities = [ "12.0" ];

  # ── Jellyfin media (256GB loopback mount) ──────────────
  fileSystems."/home/denis/jellyfin/media" = {
    device = "/home/denis/jellyfin/media.img";
    fsType = "ext4";
    options = [
      "loop"
      "noatime"
    ];
  };
}
