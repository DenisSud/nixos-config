{
  config,
  pkgs,
  ...
}:

{
  # ╔══════════════════════════════════════════════════════════╗
  # ║  g14 — ASUS ROG Zephyrus G14 laptop                      ║
  # ║      AMD Cezanne iGPU + NVIDIA RTX 3050 Mobile (hybrid)  ║
  # ╚══════════════════════════════════════════════════════════╝
  # "Lite" config: no Docker, no Steam, no LibreOffice, no Ollama.
  # Adds the full asusd + supergfxd stack for power/profile/fan
  # control and dGPU mode switching.

  imports = [
    # ── Common modules ──────────────────────────────────
    ../modules/boot.nix
    ../modules/nix.nix
    ../modules/network.nix
    ../modules/locale.nix
    ../modules/graphics.nix
    ../modules/audio.nix
    ../modules/desktop.nix
    ../modules/fonts.nix
    ../modules/services.nix
    ../modules/dev-tools.nix
    ../modules/shell-utils.nix
    ../modules/user.nix
    ../modules/programs.nix

    # ── g14-only modules ────────────────────────────────
    ../modules/asus.nix
  ];

  # ── Host identity ─────────────────────────────────────
  networking.hostName = "g14";

  # ── State version ─────────────────────────────────────
  system.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

  # ── NVIDIA (ROG Zephyrus G14 — hybrid graphics) ───────
  # Proprietary modules + Prime offload. dGPU is gated on
  # demand via `nvidia-offload` (or supergfxctl).
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true; # critical for suspend/resume + dGPU power gating
    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Verify with: lspci | grep -E 'VGA|3D'
      # Convert e.g. "01:00.0" → "PCI:1:0:0"
      amdgpuBusId = "PCI:4:0:0"; # AMD Cezanne
      nvidiaBusId = "PCI:1:0:0"; # RTX 3050 Mobile
    };

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = [
    "nvidia"
    "amdgpu"
  ];
}
