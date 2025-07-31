{ lib, ... }:
{
  imports = [
    # Import all our custom darwin modules
    ./system
    ./homebrew
    ./defaults
  ];

  options.mySystem = with lib; {
    username = mkOption {
      type = types.str;
      default = "bwright";
      description = "Primary username";
    };

    profileType = mkOption {
      type = types.enum [ "work" "personal" ];
      default = "work";
      description = "Configuration profile type";
    };

    isWayland = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use Wayland (not applicable on macOS)";
    };
  };
}
