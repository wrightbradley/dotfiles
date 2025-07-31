# Module System Documentation

This document provides comprehensive documentation for the custom module system used in the Nix-based dotfiles configuration.

## 🧩 Module System Overview

The module system provides a structured, type-safe, and composable way to organize configuration. It builds upon Nix's native module system with custom extensions for profile management and cross-system compatibility.

### Core Principles

1. **Modularity**: Each module handles a specific domain or functionality
2. **Composability**: Modules can be combined and depend on each other
3. **Type Safety**: Options are strongly typed with validation
4. **Profile Awareness**: Modules can adapt based on configuration profiles
5. **Reusability**: Modules can be shared across different systems

## 📁 Module Organization

### Module Hierarchy
```
modules/
├── darwin/                  # System-level macOS configuration
│   ├── default.nix         # Module aggregation and mySystem options
│   ├── system/             # Core system configuration
│   │   └── default.nix     # System settings and services
│   ├── homebrew/           # Homebrew integration
│   │   └── default.nix     # Homebrew packages and casks
│   └── defaults/           # macOS system defaults
│       └── default.nix     # Dock, Finder, NSGlobalDomain settings
├── home-manager/           # User-level configuration
│   ├── default.nix         # Module aggregation and myHome options
│   ├── programs/           # Package and program management
│   │   ├── default.nix     # Package organization and management
│   │   ├── external-repos.nix  # External repository management
│   │   └── secrets.nix     # Secrets and encrypted files
│   ├── shell/              # Shell and CLI configuration
│   │   ├── default.nix     # Shell module aggregation
│   │   └── git.nix         # Git configuration
│   └── dotfiles/           # Dotfile management
│       └── default.nix     # Dotfile sourcing and linking
└── shared/                 # Cross-system shared functionality
    ├── default.nix         # Shared module aggregation
    └── profiles.nix        # Profile management system
```

## 🎛️ Options System

### Custom Options Definition

#### mySystem Options (Darwin)
```nix
options.mySystem = with lib; {
  username = mkOption {
    type = types.str;
    default = "bwright";
    description = "Primary username for the system";
  };

  profileType = mkOption {
    type = types.enum [ "work" "personal" ];
    default = "work";
    description = "Configuration profile type affecting package selection and settings";
  };

  isWayland = mkOption {
    type = types.bool;
    default = false;
    description = "Whether to use Wayland (not applicable on macOS but kept for compatibility)";
  };
};
```

#### myHome Options (Home Manager)
```nix
options.myHome = with lib; {
  username = mkOption {
    type = types.str;
    default = "bwright";
    description = "Username for home-manager configuration";
  };

  profileType = mkOption {
    type = types.enum [ "work" "personal" ];
    default = "work";
    description = "Configuration profile type";
  };

  shell = {
    enable = mkEnableOption "shell configuration" // { default = true; };

    git = {
      enable = mkEnableOption "git configuration" // { default = true; };
      username = mkOption {
        type = types.str;
        default = if config.myHome.profileType == "work"
          then "Bradley Wright"
          else "wrightbradley";
        description = "Git username";
      };
      email = mkOption {
        type = types.str;
        default = if config.myHome.profileType == "work"
          then "bradley.wright@mycompany.com"
          else "b@rdleywright.com";
        description = "Git email address";
      };
    };

    fish = {
      enable = mkEnableOption "fish shell" // { default = true; };
    };

    aliases = {
      enable = mkEnableOption "shell aliases" // { default = true; };
    };
  };

  programs = {
    development = mkEnableOption "development tools" // { default = true; };
    cli = mkEnableOption "CLI utilities" // { default = true; };
    media = mkEnableOption "media tools" // { default = true; };
    work = mkEnableOption "work-specific tools" // {
      default = config.myHome.profileType == "work";
    };
    personal = mkEnableOption "personal tools" // {
      default = config.myHome.profileType == "personal";
    };
  };
};
```

### Option Types and Validation

#### Common Option Types
```nix
# String options with validation
username = mkOption {
  type = types.str;
  default = "bwright";
  example = "john.doe";
  description = "System username";
};

# Enumerated options for controlled choices
profileType = mkOption {
  type = types.enum [ "work" "personal" ];
  default = "work";
  description = "Configuration profile";
};

# Boolean options for feature toggles
enable = mkEnableOption "feature name" // { default = true; };

# List options for collections
packages = mkOption {
  type = types.listOf types.package;
  default = [];
  description = "Additional packages to install";
};

# Attribute set options for complex configuration
extraConfig = mkOption {
  type = types.attrs;
  default = {};
  description = "Additional configuration options";
};
```

## 🔗 Module Composition

### Import Patterns

#### Basic Module Import
```nix
{
  imports = [
    ./system
    ./homebrew
    ./defaults
  ];
}
```

#### Conditional Module Import
```nix
{
  imports = [
    ./base-module.nix
  ] ++ lib.optionals (config.mySystem.profileType == "work") [
    ./work-specific-module.nix
  ] ++ lib.optionals (config.mySystem.profileType == "personal") [
    ./personal-specific-module.nix
  ];
}
```

#### Dynamic Module Import
```nix
{
  imports = builtins.map (module: ./modules/${module}) [
    "essential"
    "development"
    "media"
  ];
}
```

### Module Dependencies

#### Explicit Dependencies
```nix
# Module A depends on Module B's options
{ config, lib, ... }:
let
  shellCfg = config.myHome.shell;
in {
  config = lib.mkIf shellCfg.git.enable {
    # Configuration that depends on git being enabled
  };
}
```

#### Cross-System Dependencies
```nix
# Home-manager module inheriting from system configuration
{ config, lib, osConfig ? {}, ... }:
{
  config.myHome = lib.mkDefault (lib.myLib.copyFromSystem "mySystem" osConfig);
}
```

## 🎯 Profile-Aware Configuration

### Profile Implementation Pattern

#### Option-Based Profile Selection
```nix
config = lib.mkMerge [
  # Base configuration for all profiles
  {
    programs.git.enable = true;
    programs.fish.enable = true;
  }

  # Work profile configuration
  (lib.mkIf (config.myHome.profileType == "work") {
    programs.git.extraConfig = {
      commit.gpgSign = true;
      user.signingKey = "~/.ssh/id_rsa.pub";
    };
  })

  # Personal profile configuration
  (lib.mkIf (config.myHome.profileType == "personal") {
    programs.git.extraConfig = {
      commit.gpgSign = false;
    };
  })
];
```

#### Profile Helper Functions
```nix
# Using custom lib function for profile configuration
programs.git.userEmail = lib.myLib.profileConfig {
  work = "bradley.wright@company.com";
  personal = "b@rdleywright.com";
} config.myHome.profileType;
```

### Profile Inheritance

#### System to Home Manager
```nix
# Automatically inherit profile from system configuration
config.myHome = lib.mkDefault (lib.myLib.copyFromSystem "mySystem" osConfig);
```

#### Profile Validation
```nix
# Ensure profile consistency across modules
assertions = [
  {
    assertion = builtins.elem config.myHome.profileType [ "work" "personal" ];
    message = "profileType must be either 'work' or 'personal'";
  }
];
```

## 🛠️ Module Development Patterns

### Standard Module Structure

#### Basic Module Template
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.myHome.moduleName;
  inherit (lib) mkEnableOption mkOption types mkIf;
in
{
  # Options definition
  options.myHome.moduleName = {
    enable = mkEnableOption "module description" // { default = true; };

    # Additional options
    customOption = mkOption {
      type = types.str;
      default = "default-value";
      description = "Description of the option";
    };
  };

  # Configuration implementation
  config = mkIf cfg.enable {
    # Module implementation using cfg options
  };
}
```

#### Advanced Module with Multiple Options
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.myHome.shell;
  inherit (lib) mkOption types mkEnableOption mkIf;
in
{
  options.myHome.shell = {
    enable = mkEnableOption "shell configuration" // { default = true; };

    git = {
      enable = mkEnableOption "git configuration" // { default = true; };
      username = mkOption {
        type = types.str;
        default = "Bradley Wright";
        description = "Git username";
      };
      email = mkOption {
        type = types.str;
        default = "user@example.com";
        description = "Git email";
      };
    };

    aliases = {
      enable = mkEnableOption "shell aliases" // { default = true; };
      custom = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Custom shell aliases";
      };
    };
  };

  config = mkIf cfg.enable {
    # Git configuration
    programs.git = mkIf cfg.git.enable {
      enable = true;
      userName = cfg.git.username;
      userEmail = cfg.git.email;
    };

    # Shell aliases
    programs.fish.shellAbbrs = mkIf cfg.aliases.enable (
      cfg.aliases.custom // {
        # Default aliases
        g = "git";
        ll = "eza -l";
      }
    );
  };
}
```

### Error Handling and Validation

#### Assertions
```nix
config = {
  assertions = [
    {
      assertion = cfg.enable -> (cfg.username != "");
      message = "Username cannot be empty when module is enabled";
    }
    {
      assertion = cfg.profileType == "work" -> cfg.workEmail != "";
      message = "Work email must be specified for work profile";
    }
  ];
};
```

#### Warnings
```nix
config = {
  warnings = lib.optionals (cfg.enable && cfg.deprecatedOption != null) [
    "myHome.moduleName.deprecatedOption is deprecated, use newOption instead"
  ];
};
```

## 🔄 Module Testing

### Testing Module Options
```nix
# Test module with specific configuration
let
  testConfig = {
    myHome.shell = {
      enable = true;
      git.username = "Test User";
      git.email = "test@example.com";
    };
  };

  result = (lib.evalModules {
    modules = [
      ./shell/default.nix
      { config = testConfig; }
    ];
  }).config;
in
{
  # Assertions about the result
  testGitConfig = result.programs.git.userName == "Test User";
  testEmailConfig = result.programs.git.userEmail == "test@example.com";
}
```

### Integration Testing
```nix
# Test module composition
let
  modules = [
    ./modules/home-manager/shell
    ./modules/home-manager/programs
  ];

  testProfile = "work";

  evaluation = lib.evalModules {
    modules = modules ++ [{
      config.myHome.profileType = testProfile;
    }];
  };
in
{
  # Test profile-specific behavior
  testWorkProfile = evaluation.config.myHome.programs.work.enable == true;
  testPersonalProfile = evaluation.config.myHome.programs.personal.enable == false;
}
```

## 📖 Module Documentation

### Self-Documenting Options
```nix
options.myHome.example = {
  enable = mkEnableOption "example functionality";

  configFile = mkOption {
    type = types.path;
    default = ./config/example.conf;
    example = literalExpression "./my-custom-config.conf";
    description = lib.mdDoc ''
      Path to the example configuration file.

      This file will be used to configure the example service.
      See [example documentation](https://example.com/docs) for format details.
    '';
  };

  extraOptions = mkOption {
    type = types.attrsOf types.str;
    default = {};
    example = literalExpression ''
      {
        key1 = "value1";
        key2 = "value2";
      }
    '';
    description = lib.mdDoc ''
      Additional configuration options passed to the example service.

      These options will be merged with the default configuration.
    '';
  };
};
```

### Module Examples
```nix
# Example configurations for the module
examples = {
  basic = {
    myHome.example = {
      enable = true;
    };
  };

  advanced = {
    myHome.example = {
      enable = true;
      configFile = ./custom-config.conf;
      extraOptions = {
        debug = "true";
        timeout = "30";
      };
    };
  };
};
```

This module system provides a robust foundation for organizing, composing, and maintaining complex system configurations while ensuring type safety, profile awareness, and maintainability.
