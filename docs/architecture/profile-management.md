# Profile Management System

This document details the profile management system that enables configuration switching between different usage contexts (work vs personal) while maintaining a single codebase.

## 🎭 Profile System Overview

The profile management system allows a single configuration to adapt dynamically based on the selected profile, enabling:

- **Context-Aware Configuration**: Different settings for work and personal use
- **Package Selection**: Profile-specific software installation
- **Security Isolation**: Separate credentials and sensitive configuration
- **Maintenance Efficiency**: Single codebase for multiple use cases

### Core Concepts

#### Profile Types
- **work**: Corporate/professional environment configuration
- **personal**: Personal use configuration with relaxed security and entertainment software

#### Profile Scope
- **System Level**: macOS settings, system packages, security policies
- **User Level**: Personal packages, shell configuration, development tools
- **Application Level**: App-specific settings and preferences

## 🏗️ Architecture

### Profile Resolution Flow
```
Profile Input -> Validation -> Option Resolution -> Module Configuration -> Final Output
     │               │              │                       │                  │
 "work" or       Ensure valid    Calculate profile-     Apply conditional   Generated
 "personal"      profile type    aware option values    module configs      configuration
```

### Profile Data Flow
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   flake.nix     │    │   flakeLib.nix  │    │    Modules      │
│                 │    │                 │    │                 │
│ profileType =   │───▶│ mkDarwinSystem  │───▶│ Profile-aware   │
│ "work"          │    │ passes profile  │    │ configuration   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Final Config    │◀───│ Option Values   │◀───│ Profile Logic   │
│                 │    │                 │    │                 │
│ System ready    │    │ Computed based  │    │ if work then X  │
│ for profile     │    │ on profile      │    │ else Y          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## ⚙️ Implementation Details

### Profile Configuration in Flake

#### Multiple Profile Configurations
```nix
# nix/flake.nix
{
  darwinConfigurations = {
    # Default work configuration
    "Bradleys-MacBook-Pro" = flakeLib.mkDarwinSystem {
      hostname = "Bradleys-MacBook-Pro";
      username = "bwright";
      profileType = "work";
    };

    # Personal profile configuration
    "Bradleys-MacBook-Pro-personal" = flakeLib.mkDarwinSystem {
      hostname = "Bradleys-MacBook-Pro";
      username = "bwright";
      profileType = "personal";
    };
  };

  homeConfigurations = {
    # Standalone home-manager configurations
    "bwright@work" = flakeLib.mkHome {
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
}
```

#### Profile Parameter Passing
```nix
# flakeLib.nix
mkDarwinSystem = {
  hostname,
  username ? "bwright",
  profileType ? "work",
  system ? "aarch64-darwin",
  ...
}:
nixpkgs.lib.darwinSystem {
  inherit system lib;
  specialArgs = {
    inherit inputs hostname username profileType;
  };
  modules = [
    # Profile information available to all modules
    {
      config.mySystem = {
        inherit username profileType;
      };
    }
  ] ++ baseModules;
};
```

### Profile-Aware Options

#### System-Level Profile Options
```nix
# modules/darwin/default.nix
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
};
```

#### User-Level Profile Options
```nix
# modules/home-manager/default.nix
options.myHome = with lib; {
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
};

# Automatic inheritance from system configuration
config.myHome = lib.mkDefault (lib.myLib.copyFromSystem "mySystem" osConfig);
```

### Profile-Aware Configuration Patterns

#### Conditional Configuration
```nix
# Basic conditional configuration
config = lib.mkIf (config.myHome.profileType == "work") {
  programs.git.extraConfig = {
    commit.gpgSign = true;
    user.signingKey = "~/.ssh/id_rsa.pub";
    gpg.format = "ssh";
  };
};
```

#### Merged Configuration
```nix
# Complex merged configuration
config = lib.mkMerge [
  # Base configuration for all profiles
  {
    programs.git = {
      enable = true;
      userName = cfg.git.username;
      userEmail = cfg.git.email;
    };
  }

  # Work-specific additions
  (lib.mkIf (config.myHome.profileType == "work") {
    programs.git.extraConfig = {
      commit.gpgSign = true;
      user.signingKey = "~/.ssh/id_rsa.pub";
      gpg.format = "ssh";
    };

    programs.git.includes = [
      { path = "~/.gitconfig.work"; }
    ];
  })

  # Personal-specific additions
  (lib.mkIf (config.myHome.profileType == "personal") {
    programs.git.includes = [
      { path = "~/.gitconfig.personal"; }
    ];
  })
];
```

#### Profile Helper Function
```nix
# Custom lib function for profile selection
# lib/default.nix
profileConfig = configs: profileType:
  configs.${profileType} or configs.work or (builtins.head (builtins.attrValues configs));

# Usage in modules
programs.git.userEmail = lib.myLib.profileConfig {
  work = "bradley.wright@company.com";
  personal = "b@rdleywright.com";
} config.myHome.profileType;
```

## 📦 Profile-Specific Configuration Examples

### Package Management

#### Profile-Aware Package Selection
```nix
# modules/home-manager/programs/default.nix
{
  config = {
    home.packages =
      (mkIf cfg.development developmentPackages) ++
      (mkIf cfg.cli cliPackages) ++
      (mkIf cfg.media mediaPackages) ++
      (mkIf cfg.work workPackages) ++
      (mkIf cfg.personal personalPackages);
  };

  options.myHome.programs = {
    work = mkEnableOption "work-specific tools" // {
      default = config.myHome.profileType == "work";
    };
    personal = mkEnableOption "personal tools" // {
      default = config.myHome.profileType == "personal";
    };
  };
}
```

#### Package Definitions
```nix
# Work-specific packages
workPackages = with pkgs; [
  slack zoom-us microsoft-teams
  1password 1password-cli
  terraform-ls
  azure-cli google-cloud-sdk
];

# Personal packages
personalPackages = with pkgs; [
  spotify discord steam vlc
  handbrake obs-studio
];
```

### Git Configuration

#### Profile-Aware Git Setup
```nix
# modules/home-manager/shell/git.nix
{
  options.myHome.shell.git = {
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
      description = "Git email";
    };
  };

  config = {
    programs.git = {
      userName = cfg.git.username;
      userEmail = cfg.git.email;

      # Profile-specific configuration
      extraConfig = lib.optionalAttrs (config.myHome.profileType == "work") {
        commit.gpgSign = true;
        user.signingKey = "~/.ssh/id_rsa.pub";
        gpg.format = "ssh";
      };

      # Conditional includes for profile-specific git configs
      includes = lib.optionals (config.myHome.profileType == "work") [
        { path = "~/.gitconfig.work"; }
      ] ++ lib.optionals (config.myHome.profileType == "personal") [
        { path = "~/.gitconfig.personal"; }
      ];
    };
  };
}
```

### System Preferences

#### Profile-Aware macOS Defaults
```nix
# modules/darwin/defaults/default.nix
{
  config = {
    system.defaults = {
      # Base settings for all profiles
      dock = {
        autohide = true;
        orientation = "left";
        tilesize = 36;
      };

      # Profile-specific custom preferences
      CustomUserPreferences = lib.mkMerge [
        # Common settings
        {
          "com.microsoft.VSCode" = {
            ApplePressAndHoldEnabled = false;
          };
        }

        # Work-specific settings
        (lib.mkIf (cfg.profileType == "work") {
          "com.apple.Safari" = {
            IncludeDevelopMenu = true;
            WebKitDeveloperExtrasEnabledPreferenceKey = true;
          };
          "com.apple.mail" = {
            DisableReplyAnimations = true;
            DisableSendAnimations = true;
          };
        })

        # Personal-specific settings
        (lib.mkIf (cfg.profileType == "personal") {
          "com.spotify.client" = {
            AutoPlay = false;
          };
        })
      ];
    };
  };
}
```

### Homebrew Applications

#### Profile-Specific Homebrew Casks
```nix
# modules/darwin/homebrew/default.nix
{
  config = {
    homebrew = {
      casks = [
        # Common applications
        "brave-browser"
        "firefox"
        "visual-studio-code"
        "alacritty"
        "obsidian"

      ] ++ lib.optionals (cfg.profileType == "work") [
        # Work-specific applications
        "1password"
        "microsoft-teams"
        "slack"
        "zoom"
        "loom"
        "twingate"

      ] ++ lib.optionals (cfg.profileType == "personal") [
        # Personal applications
        "spotify"
        "discord"
        "handbrake"
        "crossover"
        "backblaze"
        "mullvadvpn"
      ];
    };
  };
}
```

## 🔄 Profile Switching

### Build-Time Profile Selection

#### Switch to Work Profile
```bash
# Build work configuration
darwin-rebuild switch --flake ./nix#Bradleys-MacBook-Pro

# Or explicitly specify work profile
darwin-rebuild switch --flake ./nix#Bradleys-MacBook-Pro
```

#### Switch to Personal Profile
```bash
# Build personal configuration
darwin-rebuild switch --flake ./nix#Bradleys-MacBook-Pro-personal
```

#### Home Manager Only
```bash
# Switch home-manager configuration only
home-manager switch --flake ./nix#bwright@work
home-manager switch --flake ./nix#bwright@personal
```

### Runtime Profile Detection

#### Automatic Profile Detection
```nix
# Detect profile based on environment or hostname
profileType =
  if (builtins.getEnv "WORK_PROFILE") == "1" then "work"
  else if (builtins.match ".*-work$" config.networking.hostName) != null then "work"
  else "personal";
```

#### Profile Validation
```nix
# Ensure profile consistency
assertions = [
  {
    assertion = builtins.elem config.mySystem.profileType [ "work" "personal" ];
    message = "profileType must be either 'work' or 'personal'";
  }
  {
    assertion = config.mySystem.profileType == config.myHome.profileType;
    message = "System and home profiles must match";
  }
];
```

## 🔒 Security Considerations

### Profile Isolation

#### Secrets Management
```nix
# Profile-specific secrets
secrets = {
  work = {
    "work-ssh-key" = {
      file = ./secrets/work-ssh-key.age;
      path = "/Users/${cfg.username}/.ssh/work_id_rsa";
      mode = "0600";
    };
  };

  personal = {
    "personal-ssh-key" = {
      file = ./secrets/personal-ssh-key.age;
      path = "/Users/${cfg.username}/.ssh/personal_id_rsa";
      mode = "0600";
    };
  };
};

# Apply profile-specific secrets
sops.secrets = secrets.${config.myHome.profileType} or {};
```

#### Credential Separation
```nix
# Work profile - strict security
(lib.mkIf (cfg.profileType == "work") {
  programs.git.extraConfig = {
    commit.gpgSign = true;
    user.signingKey = "/Users/${cfg.username}/.ssh/work_id_rsa.pub";
    gpg.format = "ssh";
  };
})

# Personal profile - relaxed security
(lib.mkIf (cfg.profileType == "personal") {
  programs.git.extraConfig = {
    commit.gpgSign = false;
  };
})
```

### Data Isolation

#### Profile-Specific Directories
```nix
# Work-specific directories
(lib.mkIf (cfg.profileType == "work") {
  home.file.".ssh/config_work" = {
    text = ''
      Host *.company.com
        IdentityFile ~/.ssh/work_id_rsa
        User ${cfg.username}
    '';
  };
})
```

## 📊 Profile Comparison

### Feature Matrix

| Feature | Work Profile | Personal Profile |
|---------|-------------|------------------|
| **Git Signing** | ✅ Required | ❌ Disabled |
| **VPN Client** | ✅ Twingate | ✅ Mullvad |
| **Communication** | Slack, Teams, Zoom | Discord |
| **Entertainment** | ❌ Minimal | ✅ Spotify, Steam |
| **Cloud Tools** | AWS, Azure, GCP | ❌ None |
| **Security** | ✅ Strict | 🔄 Balanced |
| **Development** | ✅ Full stack | ✅ Personal projects |

### Package Differences

#### Exclusive to Work Profile
- Microsoft Teams, Slack, Zoom
- 1Password (corporate)
- Cloud provider CLIs (AWS, Azure, GCP)
- Corporate VPN (Twingate)
- Loom for screen recording

#### Exclusive to Personal Profile
- Spotify, Discord
- Gaming: Steam, Crossover
- Media: HandBrake, OBS Studio
- Personal VPN: Mullvad
- Backup: Backblaze

#### Shared Packages
- Development tools (Git, Neovim, languages)
- Browsers (Firefox, Brave)
- Terminal applications (Alacritty, iTerm2)
- System utilities (Finder alternatives, clipboard managers)

## 🧪 Testing Profile Configurations

### Profile Validation Tests
```nix
# Test work profile configuration
let
  workConfig = (lib.evalModules {
    modules = [ ./modules/home-manager ];
    specialArgs = { profileType = "work"; };
  }).config;
in {
  testWorkEmail = workConfig.programs.git.userEmail == "bradley.wright@company.com";
  testWorkPackages = builtins.elem pkgs.slack workConfig.home.packages;
  testWorkSigning = workConfig.programs.git.extraConfig.commit.gpgSign == true;
}

# Test personal profile configuration
let
  personalConfig = (lib.evalModules {
    modules = [ ./modules/home-manager ];
    specialArgs = { profileType = "personal"; };
  }).config;
in {
  testPersonalEmail = personalConfig.programs.git.userEmail == "b@rdleywright.com";
  testPersonalPackages = builtins.elem pkgs.spotify personalConfig.home.packages;
  testPersonalSigning = personalConfig.programs.git.extraConfig.commit.gpgSign or false == false;
}
```

The profile management system provides a robust foundation for maintaining context-aware configurations while ensuring security isolation and maintenance efficiency across different usage scenarios.
