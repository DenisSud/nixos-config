{ config, lib, pkgs, ... }:

{
  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Extra audio-related packages
  environment.systemPackages = with pkgs; [
    pulsemixer        # Terminal mixer
    pavucontrol       # GUI mixer
    easyeffects      # Audio effects
  ];
}
