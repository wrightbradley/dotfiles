# Nix Configuration for Multi-Profile Management
# Handles work/personal profile switching that chezmoi manages dynamically

{ config, pkgs, lib, ... }:

let
  # Profile detection - this would need to be set during build/activation
  # In chezmoi this is dynamic, in Nix we need to be explicit
  profileType = "work"; # or "personal" - could be set via flake input or environment

  # User data (equivalent to chezmoi's data section)
  userData = {
    email_personal = "bradley.wright.tech@gmail.com";
    email_work = "bradley.wright@tackle.io";
    ghuser = "wrightbradley";
    hwkey = "0x3BFB70FB14D1D029";
    system = profileType;
  };

  # Conditional logic for profile-specific configurations
  isWork = userData.system == "work";
  isPersonal = userData.system == "personal";

  # Email selection based on profile
  userEmail = if isWork then userData.email_work else userData.email_personal;

in {
  # Export userData for use in other modules
  _module.args = { inherit userData profileType isWork isPersonal; };

  # Profile-specific configurations would be handled here
  # This replaces chezmoi's templating system with Nix's functional approach
}
