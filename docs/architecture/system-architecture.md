# System Architecture

This document provides a comprehensive overview of the Nix-based dotfiles system architecture, design patterns, and core components.

## 🏗️ Overall Architecture

### System Overview
```
┌─────────────────────────────────────────────────────────────────┐
│                          macOS Host System                       │
├─────────────────────────────────────────────────────────────────┤
│                       Nix Package Manager                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐    ┌─────────────────────────────────┐  │
│  │     nix-darwin      │    │        home-manager             │  │
│  │  (System Config)    │    │     (User Environment)         │  │
│  │                     │    │                                 │  │
│  │ • System Settings   │    │ • User Packages                │  │
│  │ • System Packages   │    │ • Shell Configuration         │  │
│  │ • macOS Defaults    │    │ • Development Tools           │  │
│  │ • Homebrew Integration │  │ • Dotfiles Management        │  │
│  └─────────────────────┘    └─────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. **Nix Flake System**
- **Purpose**: Reproducible, declarative configuration management
- **Key Features**:
  - Hermetic builds with locked dependencies
  - Multiple configuration profiles (work/personal)
  - Composable module system
  - Rollback capabilities

#### 2. **nix-darwin**
- **Purpose**: macOS system-level configuration management
- **Manages**:
  - System preferences and defaults
  - System-wide packages
  - Homebrew integration for macOS-specific apps
  - User account configuration

#### 3. **home-manager**
- **Purpose**: User environment and dotfiles management
- **Manages**:
  - User-specific packages
  - Shell configuration and aliases
  - Development environment setup
  - Application configurations

## 🗂️ Directory Structure

```
nix/
├── flake.nix                 # Main flake definition with inputs/outputs
├── flakeLib.nix             # Helper functions for system creation
├── lib/                     # Custom utility functions
│   └── default.nix          # System utilities and helpers
├── overlays/                # Package customization and overlays
│   └── default.nix          # Stable/unstable package management
├── darwin-configuration.nix # Main nix-darwin configuration
├── home.nix                 # Main home-manager configuration
└── modules/                 # Modular configuration components
    ├── darwin/              # System-level modules
    │   ├── default.nix      # Darwin module aggregation
    │   ├── system/          # Core system configuration
    │   ├── homebrew/        # Homebrew integration
    │   └── defaults/        # macOS system defaults
    ├── home-manager/        # User-level modules
    │   ├── default.nix      # Home-manager module aggregation
    │   ├── programs/        # Package management
    │   ├── shell/           # Shell and CLI configuration
    │   └── dotfiles/        # Dotfile management
    └── shared/              # Cross-system shared modules
        └── profiles.nix     # Profile management system
```

## 🔧 Design Patterns

### 1. **Modular Architecture Pattern**

#### Module Organization
- **Separation of Concerns**: Each module handles a specific domain
- **Composition**: Modules can be combined and reused
- **Hierarchy**: Clear parent-child relationships

```nix
# Module structure example
{
  imports = [
    ./system     # System-level configuration
    ./homebrew   # macOS app management
    ./defaults   # System preferences
  ];

  options.mySystem = {
    # Custom options for this module
  };

  config = {
    # Implementation using options
  };
}
```

#### Benefits
- **Maintainability**: Easy to update individual components
- **Testability**: Modules can be tested independently
- **Reusability**: Modules can be shared across configurations

### 2. **Options System Pattern**

#### Custom Options Definition
```nix
options.myHome = {
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
};
```

#### Benefits
- **Type Safety**: Compile-time validation of configuration
- **Documentation**: Self-documenting options with descriptions
- **Defaults**: Sensible defaults reduce configuration burden

### 3. **Profile Management Pattern**

#### Profile-Aware Configuration
```nix
# Configuration that adapts based on profile
config = lib.mkMerge [
  # Base configuration for all profiles
  { /* common settings */ }

  # Profile-specific overrides
  (lib.mkIf (cfg.profileType == "work") {
    # Work-specific configuration
  })

  (lib.mkIf (cfg.profileType == "personal") {
    # Personal-specific configuration
  })
];
```

#### Implementation
- **Conditional Logic**: Profile-based configuration switching
- **Inheritance**: Common configuration with profile overrides
- **Validation**: Ensure profile consistency across modules

## 🎯 Key Design Decisions

### 1. **Flake-based Architecture**

**Decision**: Use Nix flakes for configuration management
**Rationale**:
- **Reproducibility**: Locked dependencies ensure consistent builds
- **Composability**: Easy to combine and extend configurations
- **Modern Tooling**: Access to latest Nix features and patterns

**Implementation**:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
  };
}
```

### 2. **Custom Helper Library**

**Decision**: Implement custom utility functions in `lib/`
**Rationale**:
- **Abstraction**: Simplify common patterns and operations
- **Consistency**: Standardize configuration approaches
- **Reusability**: Share utilities across modules

**Key Functions**:
- `systemEnabled`: Check if system features are enabled
- `copyFromSystem`: Inherit system configuration in home-manager
- `profileConfig`: Profile-aware configuration selection

### 3. **Dual Package Management**

**Decision**: Use Nix for most packages, Homebrew for macOS-specific apps
**Rationale**:
- **Coverage**: Nix provides most packages with better dependency management
- **macOS Integration**: Some apps require native macOS installation
- **Migration Path**: Gradual transition from existing Homebrew setup

**Implementation Strategy**:
- **Primary**: Nix packages for CLI tools, development environments
- **Secondary**: Homebrew casks for GUI applications, fonts
- **Fallback**: Manual installation for unavailable packages

### 4. **Profile-Based Configuration**

**Decision**: Support multiple configuration profiles (work/personal)
**Rationale**:
- **Flexibility**: Different requirements for different contexts
- **Privacy**: Separate work and personal configurations
- **Maintenance**: Single codebase for multiple use cases

**Profile Features**:
- **Package Selection**: Different packages per profile
- **Git Configuration**: Profile-specific email and signing
- **Application Settings**: Context-appropriate defaults

## 🔄 Data Flow

### 1. **Configuration Build Process**
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  flake.nix  │ -> │ flakeLib.nix│ -> │   Modules   │
└─────────────┘    └─────────────┘    └─────────────┘
                                             │
                                             v
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Output    │ <- │ Evaluation  │ <- │ Composition │
└─────────────┘    └─────────────┘    └─────────────┘
```

### 2. **Module Evaluation Order**
1. **Input Processing**: Parse flake inputs and arguments
2. **Library Loading**: Load custom utilities and helpers
3. **Module Imports**: Import and compose module hierarchy
4. **Option Definition**: Define and validate configuration options
5. **Configuration**: Apply configuration based on options
6. **Output Generation**: Generate system and home configurations

### 3. **Profile Resolution**
```
Profile Type Input -> Option Validation -> Module Filtering -> Configuration Output
       │                      │                    │                     │
   "work" or             Ensure valid         Enable/disable         Final config
   "personal"            profile type         profile modules        for profile
```

## 🛡️ Security Considerations

### 1. **Secrets Management**
- **Current**: GPG-encrypted files (legacy from chezmoi)
- **Planned**: Migration to sops-nix for better integration
- **Isolation**: Work and personal secrets kept separate

### 2. **Code Integrity**
- **Flake Locks**: Pinned dependencies prevent supply chain attacks
- **Hash Verification**: External sources verified with SHA hashes
- **Type Safety**: Compile-time validation prevents configuration errors

### 3. **Privilege Separation**
- **System vs User**: Clear separation between system and user configuration
- **Minimal Privileges**: Only necessary permissions granted
- **Audit Trail**: All changes tracked in Git history

## 📈 Performance Characteristics

### 1. **Build Performance**
- **Caching**: Nix build cache reduces rebuild times
- **Incremental**: Only changed components rebuilt
- **Parallel**: Independent modules built concurrently

### 2. **Runtime Performance**
- **Lazy Loading**: Configuration loaded on-demand
- **Optimized Packages**: Nix packages built with optimizations
- **Minimal Overhead**: Direct package access without wrapper layers

### 3. **Storage Efficiency**
- **Deduplication**: Nix store deduplicates identical packages
- **Garbage Collection**: Unused packages automatically cleaned
- **Compression**: Store contents compressed to save space

## 🔮 Extensibility

### 1. **Module System**
- **Pluggable**: New modules can be added without modifying core
- **Composable**: Modules can depend on and extend each other
- **Configurable**: Rich options system for customization

### 2. **Package Management**
- **Overlays**: Custom package modifications and additions
- **Multiple Sources**: Support for nixpkgs, homebrew, and custom sources
- **Version Pinning**: Flexible version management per package

### 3. **Profile System**
- **Extensible**: New profiles can be added easily
- **Inheritable**: Profiles can inherit from base configurations
- **Conditional**: Fine-grained conditional configuration support

---

This architecture provides a solid foundation for reproducible, maintainable, and extensible system configuration management while supporting the specific needs of macOS users with both work and personal computing requirements.
