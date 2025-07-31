{ inputs }:
{
  # The unstable nixpkgs set will be accessible through `pkgs.unstable`
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  # Custom package overlays
  custom-packages = final: prev: {
    # Add any custom package overrides here
    # Example:
    # myCustomPackage = prev.myCustomPackage.overrideAttrs (oldAttrs: {
    #   version = "custom-version";
    # });
  };
}
