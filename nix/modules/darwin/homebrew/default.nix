# Homebrew configuration for nix-darwin
# Handles packages that are not available in nixpkgs or are macOS-specific

{ config, pkgs, ... }:

{
  # Homebrew configuration
  homebrew = {
    enable = true;

    # Homebrew behavior
    onActivation = {
      cleanup = "zap";        # Uninstall packages not listed
      autoUpdate = true;      # Auto-update Homebrew
      upgrade = true;         # Auto-upgrade packages
    };

    # Additional Homebrew repositories
    taps = [
      # Add custom taps here as needed
      # Example: "homebrew/cask-fonts"
    ];

    # Command-line tools from Homebrew (use sparingly)
    brews = [
      # Add Homebrew formulae here only if not available in nixpkgs
      # Priority should be given to nixpkgs packages
    ];

    # macOS applications (casks)
    casks = [
      # macOS-specific applications that aren't in nixpkgs
      # Will be populated during Phase 2.1 migration
    ];

    # Mac App Store applications
    masApps = {
      # Mac App Store apps (using app ID)
      # Example: "Xcode" = 497799835;
    };
  };
}
