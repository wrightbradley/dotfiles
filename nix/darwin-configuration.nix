# nix-darwin system configuration using modern module system
{ config, pkgs, hostname, username, profileType, ... }:

{
  # Import our custom darwin modules
  imports = [
    ./modules/darwin
  ];

  # Configure our custom system options
  mySystem = {
    inherit username profileType;
  };

  # Basic system configuration
  system = {
    stateVersion = 4;
    configurationRevision = null; # Will be set by flake
  };

  # Set hostname
  networking.hostName = hostname;

  # Platform configuration
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable Nix daemon and flakes
  services.nix-daemon.enable = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" username ];
    };
  };

  # Enable shells
  programs = {
    zsh.enable = true;
    bash.enable = true;
  };

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Minimal system packages (most packages managed by home-manager)
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
}
