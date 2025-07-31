{ lib, osConfig ? {}, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    # Import all our custom home-manager modules
    ./shell
    ./programs
    ./dotfiles
  ];

  options.myHome = {
    username = mkOption {
      type = types.str;
      default = "bwright";
      description = "Username for home-manager";
    };

    profileType = mkOption {
      type = types.enum [ "work" "personal" ];
      default = "work";
      description = "Configuration profile type";
    };

    isWayland = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use Wayland";
    };
  };

  # Default to copy system configuration if available
  config.myHome = lib.mkDefault (lib.myLib.copyFromSystem "mySystem" osConfig);
}
