# Darwin system configuration module
# Handles macOS-specific system settings

{ config, pkgs, ... }:

{
  # System configuration
  system = {
    # Keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    # Startup configuration
    startup.chime = false;
  };

  # System-wide environment
  environment = {
    shells = with pkgs; [ bash zsh ];

    # System environment variables
    variables = {
      # Add system-wide environment variables here
    };
  };

  # System services
  services = {
    # Enable automatic software updates
    # nix-daemon is enabled in darwin-configuration.nix
  };
}
