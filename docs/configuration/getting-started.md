# Getting Started Guide

This comprehensive guide walks you through setting up and using the Nix-based dotfiles configuration system from initial installation to advanced customization.

## 🎯 Prerequisites

### System Requirements
- **macOS 10.15+** (Catalina or later)
- **Administrator access** for system configuration
- **Internet connection** for downloading packages
- **At least 5GB free space** for Nix store and packages

### Required Tools
```bash
# Install Xcode command line tools
xcode-select --install

# Verify installation
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer
```

## 🚀 Quick Installation

### Step 1: Install Nix with Flakes Support

```bash
# Install Nix using the Determinate Systems installer (recommended)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Alternative: Official Nix installer
# curl -L https://nixos.org/nix/install | sh
```

**Post-installation verification:**
```bash
# Restart your shell or source the profile
source ~/.nix-profile/etc/profile.d/nix.sh

# Verify Nix installation
nix --version
# Should show version 2.18.0 or later

# Verify flakes are enabled
nix flake --help
# Should show flake commands without errors
```

### Step 2: Clone and Bootstrap Configuration

```bash
# Clone the dotfiles repository
git clone https://github.com/wrightbradley/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# Bootstrap the system (this will take 10-30 minutes for first run)
nix run nix-darwin -- switch --flake ./nix#Bradleys-MacBook-Pro
```

### Step 3: Verify Installation

```bash
# Check that darwin-rebuild is available
which darwin-rebuild
# Should output: /run/current-system/sw/bin/darwin-rebuild

# Verify system configuration
darwin-rebuild --list-generations
# Should show at least one generation

# Test that home-manager is working
which home-manager
# Should output: /Users/$(whoami)/.nix-profile/bin/home-manager
```

## ⚙️ Initial Configuration

### Choose Your Profile

The system supports two profiles: **work** and **personal**. Choose based on your primary usage:

#### Work Profile (Default)
- Corporate communication tools (Slack, Teams, Zoom)
- Cloud development tools (AWS CLI, Azure CLI, GCP)
- Enhanced security (Git signing, 1Password)
- Development-focused package selection

#### Personal Profile
- Entertainment applications (Spotify, Discord)
- Gaming tools (Steam via Crossover)
- Personal cloud services (Mullvad VPN, Backblaze)
- Relaxed security settings

### Configure Profile in Flake

```bash
# Edit the flake configuration
nvim ~/.config/dotfiles/nix/flake.nix

# Find and modify the defaultProfile setting:
defaultProfile = "work";  # Change to "personal" if desired
```

### Apply Profile Configuration

```bash
# For work profile (default)
darwin-rebuild switch --flake ~/.config/dotfiles/nix#Bradleys-MacBook-Pro

# For personal profile
darwin-rebuild switch --flake ~/.config/dotfiles/nix#Bradleys-MacBook-Pro-personal
```

## 🛠️ Basic Customization

### Modifying Package Selection

#### Enable/Disable Package Categories

```bash
# Edit home configuration
nvim ~/.config/dotfiles/nix/home.nix

# Modify myHome options
config.myHome.programs = {
  development.enable = true;   # Development tools
  cli.enable = true;          # CLI utilities
  media.enable = true;        # Media processing tools
  work.enable = true;         # Work-specific tools (if work profile)
  personal.enable = false;    # Personal tools (disable for work profile)
};
```

#### Add Custom Packages

```bash
# Edit the programs module
nvim ~/.config/dotfiles/nix/modules/home-manager/programs/default.nix

# Add packages to the appropriate category
developmentPackages = with pkgs; [
  # Existing packages...
  your-new-package
];
```

### Customizing Shell Configuration

#### Modify Shell Aliases

```bash
# Edit shell configuration
nvim ~/.config/dotfiles/nix/modules/home-manager/shell/default.nix

# Add or modify aliases in shellAbbrs section
shellAbbrs = {
  # Existing aliases...
  myalias = "my-custom-command";
  proj = "cd ~/Projects";
};
```

#### Configure Git Settings

```bash
# Edit Git configuration
nvim ~/.config/dotfiles/nix/modules/home-manager/shell/git.nix

# Modify username and email defaults
username = mkOption {
  default = "Your Name";  # Change this
};
email = mkOption {
  default = "your.email@example.com";  # Change this
};
```

### System Preferences

#### Modify macOS Defaults

```bash
# Edit system defaults
nvim ~/.config/dotfiles/nix/modules/darwin/defaults/default.nix

# Example: Change dock orientation
dock = {
  orientation = "left";  # Change to "bottom", "left", or "right"
  tilesize = 48;        # Adjust dock icon size
};
```

## 🔄 Daily Workflow

### Making Changes

1. **Edit Configuration Files**
   ```bash
   # Navigate to dotfiles directory
   cd ~/.config/dotfiles

   # Edit files as needed
   nvim nix/modules/home-manager/programs/default.nix
   ```

2. **Test Changes**
   ```bash
   # Check configuration syntax
   nix flake check

   # Build without applying (safe test)
   darwin-rebuild build --flake ./nix#Bradleys-MacBook-Pro
   ```

3. **Apply Changes**
   ```bash
   # Apply system changes
   darwin-rebuild switch --flake ./nix#Bradleys-MacBook-Pro

   # Or apply only home-manager changes
   home-manager switch --flake ./nix#bwright@Bradleys-MacBook-Pro
   ```

### Common Commands

#### System Management
```bash
# Rebuild and switch system configuration
darwin-rebuild switch --flake ~/.config/dotfiles/nix

# List system generations
darwin-rebuild --list-generations

# Rollback to previous generation
sudo /nix/var/nix/profiles/system-{previous-number}-link/activate
```

#### Home Manager Operations
```bash
# Switch home configuration
home-manager switch --flake ~/.config/dotfiles/nix

# List home generations
home-manager generations

# Rollback home configuration
home-manager switch --flake ~/.config/dotfiles/nix --generation {number}
```

#### Package Management
```bash
# Search for packages
nix search nixpkgs package-name

# Temporarily install a package
nix shell nixpkgs#package-name

# Check what's installed
nix-env -q
```

### Development Environment

#### Enter Development Shell
```bash
cd ~/.config/dotfiles
nix develop

# Available tools in dev shell:
# - nixfmt: Format Nix files
# - nil: Nix language server
# - nix-tree: Visualize dependencies
# - nvd: Compare generations
```

#### Format Code
```bash
# Format all Nix files
nix develop -c nixfmt **/*.nix

# Check configuration
nix develop -c nix flake check
```

## 🔧 Advanced Configuration

### Adding New Modules

#### Create a New Module
```bash
# Create module directory
mkdir -p ~/.config/dotfiles/nix/modules/home-manager/my-new-module

# Create module file
cat > ~/.config/dotfiles/nix/modules/home-manager/my-new-module/default.nix << 'EOF'
{ config, lib, pkgs, ... }:
let
  cfg = config.myHome.myNewModule;
in
{
  options.myHome.myNewModule = {
    enable = lib.mkEnableOption "my new module";

    customOption = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "Custom configuration option";
    };
  };

  config = lib.mkIf cfg.enable {
    # Module implementation
    home.packages = with pkgs; [
      # packages for this module
    ];

    programs.someProgram = {
      enable = true;
      # configuration using cfg.customOption
    };
  };
}
EOF
```

#### Import the New Module
```bash
# Edit home-manager default.nix
nvim ~/.config/dotfiles/nix/modules/home-manager/default.nix

# Add import
imports = [
  # existing imports...
  ./my-new-module
];
```

### Profile-Specific Customization

#### Add Profile-Specific Packages
```bash
# Edit programs module
nvim ~/.config/dotfiles/nix/modules/home-manager/programs/default.nix

# Add profile-specific packages
myCustomPackages = with pkgs; [
  # packages specific to your needs
];

# Add to config
config = {
  home.packages =
    # existing package lists...
    ++ (mkIf (config.myHome.profileType == "work") myCustomPackages);
};
```

#### Profile-Specific Settings
```bash
# Edit any module to add profile-specific configuration
config = lib.mkMerge [
  # Base configuration
  { /* common settings */ }

  # Work-specific
  (lib.mkIf (config.myHome.profileType == "work") {
    # work-specific configuration
  })

  # Personal-specific
  (lib.mkIf (config.myHome.profileType == "personal") {
    # personal-specific configuration
  })
];
```

### External Repository Integration

#### Add External Configuration
```bash
# Edit external repos module
nvim ~/.config/dotfiles/nix/modules/home-manager/programs/external-repos.nix

# Add new repository
xdg.configFile."my-app" = {
  source = pkgs.fetchFromGitHub {
    owner = "username";
    repo = "my-app-config";
    rev = "commit-hash";  # Use specific commit
    sha256 = "...";       # Calculate with nix-prefetch-url
  };
  recursive = true;
};
```

#### Calculate SHA Hash
```bash
# For GitHub repositories
nix-prefetch-url --unpack https://github.com/owner/repo/archive/branch.tar.gz

# Use the output hash in your configuration
```

## 🔍 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Get detailed error information
darwin-rebuild switch --flake ./nix --show-trace

# Check syntax
nix flake check

# Verbose output
darwin-rebuild switch --flake ./nix --print-build-logs
```

#### Package Not Found
```bash
# Search for package
nix search nixpkgs package-name

# Check if package is available
nix-env -qaP | grep package-name

# Use unstable version if needed
packages = with pkgs; [
  unstable.package-name  # Available via overlay
];
```

#### Permission Issues
```bash
# Fix Nix store permissions
sudo chown -R root:nixbld /nix

# Restart Nix daemon
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Getting Help

#### Check System Status
```bash
# System information
darwin-option

# Current generation
darwin-rebuild --list-generations

# Package differences between generations
nvd diff /nix/var/nix/profiles/system-{1,2}-link
```

#### Debugging Configuration
```bash
# Evaluate specific options
nix eval .#darwinConfigurations.Bradleys-MacBook-Pro.config.mySystem.profileType

# Show configuration structure
nix show-config .#darwinConfigurations.Bradleys-MacBook-Pro
```

## 📚 Next Steps

### Learn More
1. **Read Module Documentation**: Explore specific module docs in `docs/modules/`
2. **Study Configuration Reference**: Check `docs/configuration/` for detailed guides
3. **Review Architecture**: Understand the system design in `docs/architecture/`

### Customize Further
1. **Add Personal Packages**: Extend package lists for your needs
2. **Create Custom Modules**: Build modules for specific workflows
3. **Contribute Back**: Share improvements with the community

### Stay Updated
```bash
# Update dependencies
nix flake update

# Apply updates
darwin-rebuild switch --flake ./nix
```

This getting started guide provides the foundation for using the Nix-based dotfiles system. Continue with the specific configuration guides for deeper customization options.
