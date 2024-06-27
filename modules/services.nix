{config, pkgs, ...}:
{

  services = {
  
    syncthing= {
      enable = true;
    };

    supergfxd.enable = true;

    asusd = {
      enable = true;
      enableUserService = true;
    };

    tor = {
      enable = true;
      openFirewall = true;
      relay = {
        enable = true;
        role = "relay";
      };
      settings = {
        Nickname = "toradmin";
        ORPort = 9001;
        ControlPort = 9051;
        BandWidthRate = "1 MBytes";
      };
    };

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      videoDrivers = [ "nvidia" "amdgpu" ];
      excludePackages = (with pkgs; [
          xterm
      ]);
    };

    ollama = {
      enable = true;
      # acceleration = "cuda";
    };
    
    openssh.enable = true;

    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };

}
