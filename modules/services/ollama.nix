{ config, lib, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    listenAddress = "127.0.0.1:11434";
    # models directory
    models = "~/Ollama/models/";
  };

  environment = {
    variables = {
      DEFAULT_VENDOR = "Ollama";
      DEFAULT_MODEL = "llama3.2:latest";
      OLLAMA_MODELS = "/home/denis/Ollama-models";
    };
  };

  # Open firewall port if needed
  networking.firewall = {
    allowedTCPPorts = [ 11434 ];
  };
}
