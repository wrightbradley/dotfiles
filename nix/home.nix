# Home Manager configuration with modern module system
{ config, pkgs, lib, hostname, username, profileType, ... }:

{
  # Import our custom home-manager modules
  imports = [
    ./modules/home-manager
  ];

  # Configure our custom options
  config = {
    # Set our custom home options
    myHome = {
      inherit username profileType;
    };

    # Basic home-manager settings
    home = {
      username = username;
      homeDirectory = "/Users/${username}";
      stateVersion = "24.11";

      # Global environment variables
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        GIT_EDITOR = "nvim";
        BROWSER = "firefox";
        TERMINAL = "ghostty";
        PAGER = "delta";
        KUBECONFIG = "$HOME/.kube/config";
        KUBE_EDITOR = "nvim";
        NODE_OPTIONS = "--no-deprecation --max-old-space-size=4096";
        XDG_CONFIG_HOME = "$HOME/.config";
        JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION = "true";
        YSU_IGNORED_ALIASES = "vi vim G";
        YSU_IGNORED_GLOBAL_ALIASES = "";
      };
    };

    # Enable programs through module system
    programs.home-manager.enable = true;

    # XDG configuration
    xdg = {
      enable = true;
      configHome = "${config.home.homeDirectory}/.config";
      dataHome = "${config.home.homeDirectory}/.local/share";
      cacheHome = "${config.home.homeDirectory}/.cache";
    };
  };
}
