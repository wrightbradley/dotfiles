{ inputs, mkPkgsWithSystem }:
let
  # Custom lib will be accessible with `lib.myLib.<function>`
  lib = inputs.nixpkgs.lib.extend (final: prev: {
    myLib = import ./lib { lib = final; };
  });
in
{
  mkDarwinSystem = {
    hostname,
    username ? "bwright",
    profileType ? "work",
    system ? "aarch64-darwin",
    nixpkgs ? inputs.nixpkgs,
    # extraModules for additional host-specific modules
    extraModules ? [],
  }:
  let
    pkgs = mkPkgsWithSystem system;
  in
  nixpkgs.lib.darwinSystem {
    inherit system lib;
    pkgs = pkgs;
    specialArgs = {
      inherit inputs hostname username profileType;
      # Make custom packages available
      myPkgs = inputs.self.packages.${system} or {};
    };
    modules = [
      # Base darwin configuration
      ./darwin-configuration.nix

      # Home-manager integration
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username} = import ./home.nix;
          extraSpecialArgs = {
            inherit inputs hostname username profileType;
            # For home-manager modules that check system config
            osConfig = {};
          };
          sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
            ./modules/home-manager
          ];
        };
      }

      # sops-nix for secrets management
      inputs.sops-nix.darwinModules.sops

      # Our custom modules
      ./modules/darwin

      # System options
      {
        config.mySystem = {
          username = username;
          profileType = profileType;
        };
      }
    ] ++ extraModules;
  };

  mkHome = {
    hostname,
    username ? "bwright",
    profileType ? "work",
    system ? "aarch64-darwin",
    nixpkgs ? inputs.nixpkgs,
  }:
  inputs.home-manager.lib.homeManagerConfiguration {
    inherit lib;
    pkgs = mkPkgsWithSystem system;
    extraSpecialArgs = {
      inherit inputs hostname username profileType;
      # Empty osConfig for standalone home-manager
      osConfig = {};
    };
    modules = [
      # sops-nix for secrets
      inputs.sops-nix.homeManagerModules.sops

      # Our custom home-manager modules
      ./modules/home-manager

      # User-specific configuration
      ./home.nix

      # Home options
      {
        config.myHome = {
          inherit username profileType;
        };
      }
    ];
  };
}
