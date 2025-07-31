{
  description = "Bradley's nix-darwin configuration";

  inputs = {
    # Stable nixpkgs channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    # Unstable nixpkgs for bleeding-edge packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin - macOS system configuration
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager - user environment configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix - secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nix-darwin, home-manager, sops-nix }:
  let
    # Helper function to create pkgs with overlays
    mkPkgsWithSystem = system: import nixpkgs {
      inherit system;
      overlays = builtins.attrValues (import ./overlays { inherit inputs; });
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    # Import helper library
    flakeLib = import ./flakeLib.nix {
      inherit inputs mkPkgsWithSystem;
    };

    # Profile configuration - can be overridden via specialArgs
    defaultProfile = "work"; # Change to "personal" as needed
  in
  {
    # Darwin configurations for different profiles
    darwinConfigurations = {
      # Main work configuration
      "Bradleys-MacBook-Pro" = flakeLib.mkDarwinSystem {
        hostname = "Bradleys-MacBook-Pro";
        username = "bwright";
        profileType = defaultProfile;
      };

      # Personal profile configuration
      "Bradleys-MacBook-Pro-personal" = flakeLib.mkDarwinSystem {
        hostname = "Bradleys-MacBook-Pro";
        username = "bwright";
        profileType = "personal";
      };
    };

    # Home-manager standalone configuration (for testing)
    homeConfigurations = {
      "bwright@Bradleys-MacBook-Pro" = flakeLib.mkHome {
        hostname = "Bradleys-MacBook-Pro";
        username = "bwright";
        profileType = defaultProfile;
      };
    };

    # Development shell
    devShells.aarch64-darwin.default = let
      pkgs = mkPkgsWithSystem "aarch64-darwin";
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        nixfmt-rfc-style
        nil
        nix-tree
        nix-output-monitor
        nvd
      ];
      shellHook = ''
        echo "🍎 nix-darwin development environment"
        echo "Available commands:"
        echo "  darwin-rebuild switch --flake .#Bradleys-MacBook-Pro"
        echo "  home-manager switch --flake .#bwright@Bradleys-MacBook-Pro"
      '';
    };

    # Expose packages for convenience
    darwinPackages = self.darwinConfigurations."Bradleys-MacBook-Pro".pkgs;
  };
}
