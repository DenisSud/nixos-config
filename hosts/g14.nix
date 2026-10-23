{
  config,
  lib,
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

  # ── Identity ──────────────────────────────────────────
  denis.hostName = "g14";

  # Fresh install (Oct 2026): keep the install-time state
  # version; the shared layer carries pc's historical 25.05.
  system.stateVersion = lib.mkForce "26.05";

  # ── Firewall: on — the laptop roams untrusted networks ─
  # Inbound ports are opened per service in the modules.
  # The pc keeps it off for now (see hosts/pc.nix).
  denis.firewall.enable = true;

  # ── Passwordless sudo (agent remote management) ───────
  # The pi agent on pc manages g14 over SSH — passwordless
  # wheel sudo keeps rebuilds non-interactive. g14 only;
  # the pc keeps the default (password required).
  security.sudo.wheelNeedsPassword = false;

  # ── Feature toggles ───────────────────────────────────
  denis.asus.enable = true;
  denis.voiceTyping.enable = true;
  denis.wakeOnLan.enable = true;
  denis.wakeOnLan.wifiPhy = "phy0";

  # ── g14-only user packages ────────────────────────────
  denis.userPackages = with pkgs; [
    libreoffice # Writer + Calc for .docx/.xlsx
    # bottles  # disabled: its lsfg-vk source (git.lsfg-vk.dev) drops
    # every fetchgit download; re-enable when the host cooperates.
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
