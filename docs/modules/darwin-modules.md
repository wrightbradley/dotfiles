# Darwin Modules Documentation

This document provides comprehensive documentation for the Darwin (nix-darwin) modules that handle system-level macOS configuration.

## 🍎 Darwin Modules Overview

Darwin modules manage system-level configuration for macOS, including:

- **System Settings**: macOS preferences and defaults
- **System Packages**: System-wide package installation
- **Homebrew Integration**: macOS-specific applications and tools
- **Security Configuration**: System security settings
- **User Management**: System user configuration

### Module Hierarchy

```
modules/darwin/
├── default.nix         # Module aggregation and mySystem options
├── system/             # Core system configuration
│   └── default.nix     # System settings and services
├── homebrew/           # Homebrew integration
│   └── default.nix     # Homebrew packages and casks
└── defaults/           # macOS system defaults
    └── default.nix     # Dock, Finder, NSGlobalDomain settings
```

## ⚙️ Core System Module (system/)

### Purpose
Handles fundamental system configuration including Nix settings, shell configuration, and core system services.

### Configuration

```nix
# modules/darwin/system/default.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.mySystem;
in
{
  config = {
    # Basic system configuration
    system = {
      stateVersion = 4;
      configurationRevision = null; # Set by flake
    };

    # Nix daemon and settings
    services.nix-daemon.enable = true;
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = [ "root" cfg.username ];
      };
    };

    # Shell programs
    programs = {
      zsh.enable = true;
      bash.enable = true;
    };

    # User configuration
    users.users.${cfg.username} = {
      name = cfg.username;
      home = "/Users/${cfg.username}";
      shell = pkgs.zsh;
    };

    # Minimal system packages (most managed by home-manager)
    environment.systemPackages = with pkgs; [
      git
      vim
    ];
  };
}
```

### Key Features

#### 1. **Nix Configuration**
- **Flakes Support**: Enables experimental flakes feature
- **Trusted Users**: Configures trusted users for Nix operations
- **Daemon Management**: Ensures nix-daemon is running

#### 2. **Shell Integration**
- **Zsh Support**: Primary shell with completion support
- **Bash Fallback**: Backup shell configuration
- **Path Integration**: Proper PATH configuration for Nix

#### 3. **User Management**
- **User Creation**: Ensures system user exists
- **Home Directory**: Sets up user home directory
- **Shell Assignment**: Assigns default shell

## 🍺 Homebrew Module (homebrew/)

### Purpose
Manages Homebrew integration for macOS-specific applications, fonts, and tools not available in nixpkgs.

### Configuration Structure

```nix
# modules/darwin/homebrew/default.nix
{ config, lib, ... }:
let
  cfg = config.mySystem;
in
{
  config = {
    homebrew = {
      enable = true;

      # Homebrew management settings
      onActivation = {
        cleanup = "zap";      # Remove unlisted packages
        autoUpdate = true;    # Update Homebrew automatically
        upgrade = true;       # Upgrade packages automatically
      };

      # Package sources (taps)
      taps = [
        # Development and DevOps tools
        "aquasecurity/trivy"
        "aws/tap"
        "charmbracelet/tap"
        "derailed/popeye"
        "fairwindsops/tap"
        "goreleaser/tap"
        "kubescape/tap"
        "lindell/multi-gitter"
        "mike-engel/jwt-cli"
        "norwoodj/tap"
        "oven-sh/bun"
        "theden/gcopy"
        "updatecli/updatecli"
        "veeso/termscp"
        "weaveworks/tap"

        # Personal and work specific taps
        "cirruslabs/cli"
        "tilt-dev/tap"
        "ankitpokhrel/jira-cli"
      ];

      # Command-line tools (minimal - prefer nixpkgs)
      brews = [
        "dockutil"  # For dock management (macOS specific)
      ];

      # GUI applications and fonts
      casks = [
        # Common applications for all profiles
        "brave-browser"
        "firefox"
        "google-chrome"
        "mullvad-browser"
        "visual-studio-code"
        "rancher"
        "obs"
        "alacritty"
        "ghostty"
        "iterm2"
        "obsidian"
        "maccy"
        "hiddenbar"
        "homerow"
        "keycastr"
        "flameshot"
        "syncthing"
        "vlc"

        # Fonts
        "font-caskaydia-cove-nerd-font"
        "font-droid-sans-mono-nerd-font"
        "font-fira-code-nerd-font"
        "font-hack-nerd-font"
        "font-jetbrains-mono"
        "font-jetbrains-mono-nerd-font"
        "font-symbols-only-nerd-font"

        # Hardware/peripherals
        "elgato-camera-hub"
        "elgato-control-center"
        "elgato-stream-deck"
        "elgato-wave-link"
        "logi-options-plus"
        "yubico-authenticator"
        "yubico-yubikey-manager"
        "keymapp"

      ] ++ lib.optionals (cfg.profileType == "work") [
        # Work-specific applications
        "1password"
        "amazon-chime"
        "loom"
        "microsoft-teams"
        "twingate"
        "slack"
        "zoom"

      ] ++ lib.optionals (cfg.profileType == "personal") [
        # Personal applications
        "authy"
        "backblaze"
        "balenaetcher"
        "blackhole-2ch"
        "crossover"
        "disk-inventory-x"
        "handbrake"
        "mullvadvpn"
        "propresenter"
        "raspberry-pi-imager"
        "rustdesk"
        "spotify"
        "discord"
      ];

      # Mac App Store applications
      masApps = {
        "Brother iPrint&Scan" = 1193539993;
        "iStat Menus" = 1319778037;
        "Bitwarden" = 1352778147;
        "Goodnotes" = 1444383602;
        "Bible Study" = 472790630;
        "GarageBand" = 682658836;
        "iA Writer" = 775737590;
        "iMovie" = 408981434;
      };
    };
  };
}
```

### Key Features

#### 1. **Profile-Aware Package Management**
- **Conditional Casks**: Different applications per profile
- **Work Applications**: Corporate tools (Teams, Slack, 1Password)
- **Personal Applications**: Entertainment and personal tools

#### 2. **Comprehensive Application Coverage**
- **Browsers**: Multiple browser options
- **Development**: IDEs and development tools
- **Communication**: Chat and video conferencing
- **Utilities**: System utilities and productivity tools
- **Fonts**: Complete Nerd Font collection

#### 3. **macOS Integration**
- **Mac App Store**: Native App Store applications
- **Hardware Support**: Device-specific software
- **System Integration**: Tools that require native installation

### Package Categories

#### Essential Applications (All Profiles)
```nix
commonCasks = [
  "firefox"                # Primary browser
  "visual-studio-code"     # Code editor
  "alacritty"             # Terminal emulator
  "obsidian"              # Note-taking
  "maccy"                 # Clipboard manager
  "hiddenbar"             # Menu bar management
];
```

#### Work-Specific Applications
```nix
workCasks = [
  "1password"             # Password manager
  "microsoft-teams"       # Communication
  "slack"                 # Team chat
  "zoom"                  # Video conferencing
  "loom"                  # Screen recording
  "twingate"              # VPN client
];
```

#### Personal Applications
```nix
personalCasks = [
  "spotify"               # Music streaming
  "discord"               # Gaming communication
  "handbrake"            # Video transcoding
  "mullvadvpn"           # Personal VPN
  "backblaze"            # Cloud backup
];
```

## 🎛️ System Defaults Module (defaults/)

### Purpose
Manages macOS system preferences, including Dock, Finder, NSGlobalDomain, and other system settings.

### Configuration Overview

```nix
# modules/darwin/defaults/default.nix
{ config, lib, ... }:
let
  cfg = config.mySystem;
in
{
  config = {
    system.defaults = {
      # Dock configuration
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        expose-animation-duration = 0.1;
        launchanim = false;
        magnification = false;
        minimize-to-application = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        show-process-indicators = true;
        show-recents = false;
        static-only = true;
        tilesize = 48;
      };

      # Finder configuration
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf"; # Current folder
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv"; # List view
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      # Trackpad configuration
      trackpad = {
        Clicking = true;
        Dragging = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      # Global system preferences
      NSGlobalDomain = {
        # Appearance
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;

        # Keyboard
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        # Text and input
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        # Window behavior
        NSWindowResizeTime = 0.001;
      };

      # Screen saver and security
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      # Profile-specific preferences
      CustomUserPreferences = lib.mkMerge [
        # Common application settings
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

    # Security settings
    security.pam.enableSudoTouchId = true;
  };
}
```

### Key Configuration Areas

#### 1. **Dock Management**
- **Auto-hide**: Dock automatically hides when not in use
- **Size and Position**: Optimal size and position settings
- **Behavior**: Minimize to application, disable recent items
- **Performance**: Reduced animation times for better performance

#### 2. **Finder Enhancement**
- **Visibility**: Show all files and extensions
- **Search**: Default to current folder search
- **Interface**: Path bar, status bar, list view
- **Warnings**: Disable extension change warnings

#### 3. **Input Configuration**
- **Keyboard**: Fast key repeat, disabled press-and-hold
- **Trackpad**: Tap to click, three-finger drag
- **Text**: Disabled automatic corrections and substitutions

#### 4. **System Behavior**
- **Appearance**: Dark mode by default
- **Performance**: Reduced animation times
- **Security**: Screen saver password protection
- **TouchID**: Enabled for sudo operations

### Profile-Specific Settings

#### Work Profile Enhancements
```nix
workSettings = {
  "com.apple.Safari" = {
    IncludeDevelopMenu = true;
    WebKitDeveloperExtrasEnabledPreferenceKey = true;
  };
  "com.apple.mail" = {
    DisableReplyAnimations = true;
    DisableSendAnimations = true;
  };
};
```

#### Personal Profile Customizations
```nix
personalSettings = {
  "com.spotify.client" = {
    AutoPlay = false;
  };
};
```

## 🔧 Module Options System

### mySystem Options

```nix
# modules/darwin/default.nix
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

### Option Usage Patterns

#### Profile-Based Conditional Configuration
```nix
config = lib.mkIf (config.mySystem.profileType == "work") {
  # Work-specific system configuration
};
```

#### Option Inheritance
```nix
# Pass system options to modules
specialArgs = {
  inherit (config.mySystem) username profileType;
};
```

## 🔄 Module Integration

### Cross-Module Dependencies

#### System → Home Manager
```nix
# System configuration passed to home-manager
home-manager.extraSpecialArgs = {
  inherit (config.mySystem) username profileType;
};
```

#### Validation and Consistency
```nix
assertions = [
  {
    assertion = config.mySystem.username != "";
    message = "System username cannot be empty";
  }
  {
    assertion = builtins.elem config.mySystem.profileType [ "work" "personal" ];
    message = "Profile type must be work or personal";
  }
];
```

### Module Activation Order

1. **System Module**: Basic system configuration and user setup
2. **Defaults Module**: macOS system preferences
3. **Homebrew Module**: Third-party applications and tools
4. **Home Manager**: User environment configuration

## 📊 Configuration Examples

### Minimal System Configuration
```nix
{
  mySystem = {
    username = "bwright";
    profileType = "personal";
  };
}
```

### Advanced Work Configuration
```nix
{
  mySystem = {
    username = "bwright";
    profileType = "work";
  };

  # Additional work-specific settings
  system.defaults.CustomUserPreferences = {
    "com.company.app" = {
      EnableCorporateFeatures = true;
    };
  };
}
```

## 🧪 Testing Darwin Modules

### System Configuration Testing
```bash
# Test system configuration
sudo darwin-rebuild build --flake .#Bradleys-MacBook-Pro

# Validate specific options
darwin-option mySystem.profileType

# Check system defaults
defaults read com.apple.dock autohide
```

### Profile Testing
```bash
# Test work profile
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro

# Test personal profile
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro-personal

# Compare configurations
nvd diff /nix/var/nix/profiles/system-{1,2}-link
```

The Darwin modules provide comprehensive system-level configuration for macOS, enabling declarative management of system settings, applications, and user environments while supporting multiple usage profiles.
