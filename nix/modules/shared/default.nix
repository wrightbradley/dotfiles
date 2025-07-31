# Shared modules
# Configuration that applies to both system and user levels

{ config, pkgs, lib, ... }:

{
  imports = [
    ./profiles.nix
  ];

  # Shared configuration that can be imported by both darwin and home-manager
  # This includes:
  # - Profile management (work vs personal)
  # - Common environment variables
  # - Shared aliases and functions
  # - Common program configurations
}
