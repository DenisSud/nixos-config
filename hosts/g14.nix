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
  # Thin host: imports the shared layer and sets `denis.*` values.
  # "Lite" config: no Docker, no Steam (feature toggles off).
  # Hardware-specific bits (NVIDIA/Prime) stay below.
  imports = [ ../modules/shared.nix ];

  # ── Host identity ─────────────────────────────────────
  denis.hostName = "g14";

  # ── Firewall: on — the laptop roams untrusted networks ─
  # Inbound ports are opened per service in the modules.
  # The pc keeps it off for now (see hosts/pc.nix).
  denis.firewall.enable = true;

  # ── Feature toggles ───────────────────────────────────
  denis.asus.enable = true;

  # ── g14-only user packages ────────────────────────────
  denis.userPackages = with pkgs; [
    libreoffice # Writer + Calc for .docx/.xlsx
    bottles # Wine prefix manager
  ];

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
