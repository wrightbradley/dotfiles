# Flake Design and Architecture

This document provides comprehensive documentation for the Nix flake design, covering the flake structure, helper functions, input management, and architectural decisions.

## 🌊 Flake Overview

The flake serves as the entry point for the entire configuration system, providing:

- **Reproducible Builds**: Locked inputs ensure consistent environments
- **Composable Architecture**: Helper functions for creating configurations
- **Multi-Platform Support**: Support for different systems and profiles
- **Development Workflow**: Integrated development shell and tooling

### Core Components

1. **flake.nix**: Main flake definition with inputs and outputs
2. **flakeLib.nix**: Helper functions for system and home creation
3. **lib/**: Custom utility functions and helpers
4. **overlays/**: Package customization and overlay management

## 📝 Flake Structure

### Complete Flake Definition

```nix
# nix/flake.nix
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

    # Profile configuration
    defaultProfile = "work";
  in
  {
    # Darwin configurations for different profiles
    darwinConfigurations = {
      "Bradleys-MacBook-Pro" = flakeLib.mkDarwinSystem {
        hostname = "Bradleys-MacBook-Pro";
        username = "bwright";
        profileType = defaultProfile;
      };

      "Bradleys-MacBook-Pro-personal" = flakeLib.mkDarwinSystem {
        hostname = "Bradleys-MacBook-Pro";
        username = "bwright";
        profileType = "personal";
      };
    };

    # Home-manager standalone configurations
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
        nixfmt-rfc-style nil nix-tree nix-output-monitor nvd
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
```

## 🧰 Helper Functions (flakeLib.nix)

### Core Helper Functions

```nix
# nix/flakeLib.nix
{ inputs, mkPkgsWithSystem }:
let
  # Custom lib with extended functionality
  lib = inputs.nixpkgs.lib.extend (final: prev: {
    myLib = import ./lib { lib = final; };
  });
in
{
  # Create nix-darwin system configuration
  mkDarwinSystem = {
    hostname,
    username ? "bwright",
    profileType ? "work",
    system ? "aarch64-darwin",
    nixpkgs ? inputs.nixpkgs,
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

  # Create standalone home-manager configuration
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
      osConfig = {};
    };
    modules = [
      inputs.sops-nix.homeManagerModules.sops
      ./modules/home-manager
      ./home.nix
      {
        config.myHome = {
          inherit username profileType;
        };
      }
    ];
  };
}
```

### Design Benefits

#### 1. **Abstraction and Reusability**
- **Simplified Creation**: Complex system creation reduced to simple function calls
- **Parameter Standardization**: Consistent interface for all configurations
- **Code Reuse**: Common patterns abstracted into reusable functions

#### 2. **Type Safety and Validation**
- **Parameter Validation**: Function signatures enforce correct parameter types
- **Default Values**: Sensible defaults reduce configuration burden
- **Error Prevention**: Compile-time validation prevents common mistakes

#### 3. **Maintainability**
- **Single Source of Truth**: System creation logic centralized
- **Easy Updates**: Changes propagate to all configurations
- **Clear Interface**: Well-defined parameters make usage obvious

## 📦 Input Management

### Input Strategy

#### Channel Selection
```nix
inputs = {
  # Stable channel for system reliability
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

  # Unstable for latest packages when needed
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
};
```

#### Input Following Pattern
```nix
# Ensure consistent nixpkgs across all inputs
nix-darwin = {
  url = "github:LnL7/nix-darwin";
  inputs.nixpkgs.follows = "nixpkgs";  # Use our nixpkgs
};

home-manager = {
  url = "github:nix-community/home-manager/release-24.11";
  inputs.nixpkgs.follows = "nixpkgs";  # Consistent nixpkgs
};
```

#### Benefits of Input Following
- **Consistency**: Same nixpkgs version across all tools
- **Reduced Closure**: Fewer duplicate packages in store
- **Faster Builds**: Shared dependencies build once
- **Version Alignment**: Prevents version conflicts

### Package Source Management

#### Overlay Integration
```nix
# Create pkgs with overlays applied
mkPkgsWithSystem = system: import nixpkgs {
  inherit system;
  overlays = builtins.attrValues (import ./overlays { inherit inputs; });
  config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };
};
```

#### Overlay Structure
```nix
# overlays/default.nix
{ inputs }:
{
  # Unstable packages overlay
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  # Custom package modifications
  custom-packages = final: prev: {
    # Package customizations go here
  };
}
```

## 🎛️ Configuration Outputs

### Darwin Configurations

#### Multi-Profile Support
```nix
darwinConfigurations = {
  # Primary work configuration
  "Bradleys-MacBook-Pro" = flakeLib.mkDarwinSystem {
    hostname = "Bradleys-MacBook-Pro";
    username = "bwright";
    profileType = "work";
  };

  # Personal profile variant
  "Bradleys-MacBook-Pro-personal" = flakeLib.mkDarwinSystem {
    hostname = "Bradleys-MacBook-Pro";
    username = "bwright";
    profileType = "personal";
  };
};
```

#### Usage Examples
```bash
# Build work configuration
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro

# Build personal configuration
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro-personal

# Test build without applying
darwin-rebuild build --flake .#Bradleys-MacBook-Pro
```

### Home Manager Configurations

#### Standalone Home Configurations
```nix
homeConfigurations = {
  "bwright@Bradleys-MacBook-Pro" = flakeLib.mkHome {
    hostname = "Bradleys-MacBook-Pro";
    username = "bwright";
    profileType = "work";
  };

  "bwright@personal" = flakeLib.mkHome {
    hostname = "Bradleys-MacBook-Pro";
    username = "bwright";
    profileType = "personal";
  };
};
```

#### Usage Examples
```bash
# Switch home-manager only
home-manager switch --flake .#bwright@Bradleys-MacBook-Pro

# Build without applying
home-manager build --flake .#bwright@Bradleys-MacBook-Pro
```

## 🛠️ Development Environment

### Development Shell

#### Shell Configuration
```nix
devShells.aarch64-darwin.default = let
  pkgs = mkPkgsWithSystem "aarch64-darwin";
in pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nix development tools
    nixfmt-rfc-style    # Code formatting
    nil                 # Language server
    nix-tree           # Dependency visualization
    nix-output-monitor # Build monitoring
    nvd                # Version diff tool
  ];

  shellHook = ''
    echo "🍎 nix-darwin development environment"
    echo ""
    echo "Available commands:"
    echo "  darwin-rebuild switch --flake .#Bradleys-MacBook-Pro"
    echo "  home-manager switch --flake .#bwright@Bradleys-MacBook-Pro"
    echo "  nix flake check                    # Validate configuration"
    echo "  nixfmt **/*.nix                   # Format Nix files"
    echo "  nix flake update                  # Update inputs"
    echo ""
    echo "Development tools:"
    echo "  nil         # Nix language server for editors"
    echo "  nix-tree    # Visualize dependency tree"
    echo "  nvd         # Compare system generations"
  '';
};
```

#### Usage
```bash
# Enter development environment
nix develop

# Or run commands directly
nix develop -c nixfmt **/*.nix
nix develop -c nix flake check
```

### Package Exposure

#### Convenient Package Access
```nix
# Expose packages for easy access
darwinPackages = self.darwinConfigurations."Bradleys-MacBook-Pro".pkgs;
```

#### Usage Examples
```bash
# Access packages from the configuration
nix build .#darwinPackages.firefox
nix shell .#darwinPackages.neovim
```

## 🔄 Flake Operations

### Common Commands

#### Building and Switching
```bash
# Build configuration
nix build .#darwinConfigurations.Bradleys-MacBook-Pro.system

# Switch to configuration
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro

# Switch with logging
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro --show-trace
```

#### Validation and Testing
```bash
# Check flake validity
nix flake check

# Show flake info
nix flake show

# Update inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

#### Development Workflow
```bash
# Format code
nix develop -c nixfmt **/*.nix

# Validate syntax
nix develop -c nix flake check --no-build

# Compare generations
nix develop -c nvd diff /nix/var/nix/profiles/system-{1,2}-link
```

## 🎯 Design Patterns

### 1. **Functional Composition Pattern**

#### Helper Function Composition
```nix
# Compose multiple helper functions
mkAdvancedSystem = args:
  addSecrets (addDevelopmentTools (mkDarwinSystem args));

# Chain transformations
system = mkDarwinSystem baseConfig
  |> addProfileSpecificPackages
  |> addSecurityHardening
  |> validateConfiguration;
```

### 2. **Configuration Inheritance Pattern**

#### Base Configuration Extension
```nix
# Base configuration
baseSystemConfig = {
  hostname = "Bradleys-MacBook-Pro";
  username = "bwright";
};

# Extended configurations
workConfig = baseSystemConfig // {
  profileType = "work";
  extraModules = [ ./work-specific-module.nix ];
};

personalConfig = baseSystemConfig // {
  profileType = "personal";
  extraModules = [ ./personal-specific-module.nix ];
};
```

### 3. **Parameterized Configuration Pattern**

#### Template-Based System Creation
```nix
# Configuration template
mkSystemVariant = profile: extraConfig: flakeLib.mkDarwinSystem ({
  hostname = "Bradleys-MacBook-Pro";
  username = "bwright";
  profileType = profile;
} // extraConfig);

# Generate multiple variants
darwinConfigurations = {
  "work" = mkSystemVariant "work" {
    extraModules = [ ./modules/work-security.nix ];
  };
  "personal" = mkSystemVariant "personal" {
    extraModules = [ ./modules/gaming.nix ];
  };
  "minimal" = mkSystemVariant "work" {
    extraModules = [ ./modules/minimal.nix ];
  };
};
```

## 🔍 Debugging and Introspection

### Flake Debugging

#### Show Configuration Structure
```bash
# Show all flake outputs
nix flake show

# Show specific configuration
nix show-config .#darwinConfigurations.Bradleys-MacBook-Pro

# Evaluate specific options
nix eval .#darwinConfigurations.Bradleys-MacBook-Pro.config.mySystem.profileType
```

#### Build Debugging
```bash
# Build with full trace
darwin-rebuild build --flake .#Bradleys-MacBook-Pro --show-trace

# Show build log
darwin-rebuild build --flake .#Bradleys-MacBook-Pro --print-build-logs

# Debug evaluation
nix eval --debug .#darwinConfigurations.Bradleys-MacBook-Pro
```

### Configuration Inspection

#### Option Value Inspection
```bash
# Show all options
darwin-option

# Show specific option value
darwin-option mySystem.profileType

# Show option documentation
darwin-option -d mySystem.profileType
```

#### System Information
```bash
# Show current generation
darwin-rebuild --list-generations

# Show generation differences
nvd diff /nix/var/nix/profiles/system-{1,2}-link

# Show package differences
nix store diff-closures /nix/var/nix/profiles/system-{1,2}-link
```

This flake design provides a robust, maintainable, and extensible foundation for managing complex system configurations while supporting multiple profiles and development workflows.
