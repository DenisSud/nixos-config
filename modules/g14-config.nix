{ config, pkgs, ... }:

{
  # ── Host Identity ─────────────────────────────────────
  networking.hostName = "g14";

  # ── Kernel ────────────────────────────────────────────
  # Consider matching your PC config or using a zen kernel:
  # boot.kernelPackages = pkgs.linuxPackages_zen;

  # ── NVIDIA (ROG Zephyrus G14 — hybrid graphics) ───────
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # Proprietary modules recommended for hybrid laptops
    powerManagement.enable = true; # Critical for suspend/resume + dGPU power gating
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

  # ── ASUS-specific ─────────────────────────────────────
  # Uncomment after adding the asus-linux flake input:
  # services.supergfxd.enable = true;
  # environment.systemPackages = [ pkgs.asusctl ];

  # ── Laptop Power ──────────────────────────────────────
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
      };
      charger = {
        governor = "performance";
      };
    };
  };
}

