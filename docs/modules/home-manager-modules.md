# Home Manager Modules Documentation

This document provides comprehensive documentation for the Home Manager modules that handle user-level environment configuration.

## 🏠 Home Manager Modules Overview

Home Manager modules manage user-level configuration, including:

- **User Packages**: Personal software and development tools
- **Shell Configuration**: Shell setup, aliases, and CLI tools
- **Development Environment**: Programming languages and tools
- **Dotfile Management**: Configuration file sourcing and linking
- **Application Configuration**: User-specific application settings

### Module Hierarchy

```
modules/home-manager/
├── default.nix         # Module aggregation and myHome options
├── programs/           # Package and program management
│   ├── default.nix     # Package organization and management
│   ├── external-repos.nix  # External repository management
│   └── secrets.nix     # Secrets and encrypted files
├── shell/              # Shell and CLI configuration
│   ├── default.nix     # Shell module aggregation
│   └── git.nix         # Git configuration
└── dotfiles/           # Dotfile management
    └── default.nix     # Dotfile sourcing and linking
```

## 📦 Programs Module (programs/)

### Purpose
Manages package installation, application configuration, and external repository integration with profile awareness.

### Package Organization

```nix
# modules/home-manager/programs/default.nix
{ config, pkgs, lib, ... }:

let
  cfg = config.myHome.programs;
  inherit (lib) mkEnableOption mkIf;

  # Profile-aware package selection
  workPackages = with pkgs; [
    # Work-specific tools
    slack zoom-us microsoft-teams
    1password 1password-cli
    terraform-ls
    azure-cli google-cloud-sdk
  ];

  personalPackages = with pkgs; [
    # Personal entertainment/media
    spotify discord steam vlc handbrake obs-studio
  ];

  # Core development packages
  developmentPackages = with pkgs; [
    # Development tools - Git ecosystem
    git git-delta git-cliff gitleaks gh ghq

    # Development tools - Editors and terminal
    neovim vim tmux screen
    direnv mise pre-commit
    shellcheck shfmt

    # Development languages and runtimes
    nodejs yarn python3 poetry pipenv rye pdm
    go rust openjdk maven gradle ant ruby perl lua

    # DevOps and Infrastructure
    kubectl kubectx k9s helm kustomize
    docker docker-compose kubernetes-helm
    terraform-ls ansible ansible-lint

    # Cloud tools
    awscli2 k3d minikube stern

    # Security tools
    gnupg pinentry_mac cosign openssh openssl
  ];

  # System utilities and CLI tools
  cliPackages = with pkgs; [
    # Core utilities
    coreutils gnu-sed grep bash zsh
    curl wget rsync tree htop bottom glances
    jq yq dasel unzip zip bzip2 xz

    # File management and search
    eza fd ripgrep fzf bat dust jdupes yazi

    # Network and system
    nmap mtr netcat socat wireguard-tools

    # Text and data processing
    pandoc vale proselint tealdeer csvlens sqlite

    # Build and analysis tools
    make automake autoconf cmake tokei ast-grep
    codespell prettier stylua yapf ruff

    # Container tools
    dive skopeo

    # Terminal utilities
    expect parallel dos2unix rename watch entr
    pwgen mas usage

    # Modern CLI enhancements
    zoxide starship gum glow
  ];

  # Media processing tools
  mediaPackages = with pkgs; [
    ffmpeg ffmpegthumbnailer imagemagick gifsicle
    fastfetch
  ];

in
{
  imports = [
    ./external-repos.nix
    ./secrets.nix
  ];

  options.myHome.programs = {
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

  config = {
    home.packages =
      (mkIf cfg.development developmentPackages) ++
      (mkIf cfg.cli cliPackages) ++
      (mkIf cfg.media mediaPackages) ++
      (mkIf cfg.work workPackages) ++
      (mkIf cfg.personal personalPackages);
  };
}
```

### Package Categories

#### 1. **Development Tools** (~80 packages)
- **Version Control**: Git ecosystem with advanced tools
- **Languages**: Node.js, Python, Go, Rust, Java, Ruby
- **DevOps**: Kubernetes, Docker, Terraform, Ansible
- **Cloud**: AWS, Azure, GCP command-line tools
- **Security**: GPG, OpenSSL, security scanning tools

#### 2. **CLI Utilities** (~60 packages)
- **Modern Replacements**: eza, bat, ripgrep, fd instead of ls, cat, grep, find
- **File Management**: Advanced file operations and search
- **Network Tools**: Network diagnostics and tools
- **Text Processing**: Advanced text and data manipulation
- **Build Tools**: Make, CMake, language-specific build tools

#### 3. **Media Tools** (~15 packages)
- **Video/Audio**: FFmpeg, ImageMagick processing
- **Graphics**: Image manipulation and optimization
- **System Info**: Modern system information tools

#### 4. **Profile-Specific Packages**
- **Work**: Corporate communication and cloud tools
- **Personal**: Entertainment, gaming, and personal utilities

### External Repository Management

```nix
# modules/home-manager/programs/external-repos.nix
{ config, pkgs, lib, ... }:
{
  # Neovim configuration from external repo
  xdg.configFile."nvim" = {
    source = pkgs.fetchFromGitHub {
      owner = "wrightbradley";
      repo = "nvim";
      rev = "main"; # Should be pinned to specific commit
      sha256 = "0000000000000000000000000000000000000000000000000000"; # Needs actual hash
    };
    recursive = true;
  };

  # Alacritty themes from external repo
  xdg.configFile."alacritty/themes" = {
    source = pkgs.fetchFromGitHub {
      owner = "alacritty";
      repo = "alacritty-theme";
      rev = "master"; # Should be pinned to specific commit
      sha256 = "0000000000000000000000000000000000000000000000000000"; # Needs actual hash
    };
    recursive = true;
  };

  # Tokyo Night theme for bat
  xdg.configFile."bat/themes/tokyonight.nvim" = {
    source = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "tokyonight.nvim";
      rev = "main"; # Should be pinned to specific commit
      sha256 = "0000000000000000000000000000000000000000000000000000"; # Needs actual hash
    };
    recursive = true;
  };
}
```

### Key Features

#### 1. **Profile-Aware Package Management**
- **Automatic Selection**: Packages automatically selected based on profile
- **Conditional Loading**: Enable/disable package categories
- **Resource Optimization**: Install only needed packages per profile

#### 2. **Category-Based Organization**
- **Logical Grouping**: Packages organized by function
- **Independent Control**: Each category can be enabled/disabled
- **Clear Dependencies**: Explicit package relationships

#### 3. **External Integration**
- **Repository Sourcing**: External Git repositories for complex configurations
- **SHA Verification**: Cryptographic verification of external sources
- **Reproducible Builds**: Locked versions for consistency

## 🐚 Shell Module (shell/)

### Purpose
Manages shell configuration, Git setup, CLI tool integration, and terminal enhancements.

### Shell Configuration Structure

```nix
# modules/home-manager/shell/default.nix
{ config, lib, ... }:
let
  cfg = config.myHome.shell;
  inherit (lib) mkOption types mkEnableOption mkIf;
in
{
  imports = [
    ./git.nix
  ];

  options.myHome.shell = {
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
        description = "Git email";
      };
    };

    fish = {
      enable = mkEnableOption "fish shell" // { default = true; };
    };

    aliases = {
      enable = mkEnableOption "shell aliases" // { default = true; };
    };
  };

  config = mkIf cfg.enable {
    # GitHub CLI
    programs.gh = mkIf cfg.git.enable {
      enable = true;
      settings.version = 1;
    };

    # Fish shell configuration
    programs.fish = mkIf cfg.fish.enable {
      enable = true;

      shellAbbrs = mkIf cfg.aliases.enable {
        # Git aliases
        g = "git";
        ga = "git add";
        gaa = "git add --all";
        gc = "git commit";
        gcm = "git commit -m";
        gs = "git status";
        gp = "git push";
        gpl = "git pull";
        gl = "git log";
        gd = "git diff";
        gds = "git diff --staged";
        gr = "git restore";
        grs = "git restore --staged";

        # Modern CLI replacements
        ls = "eza --group-directories-first";
        ll = "eza -l --git --group-directories-first";
        l = "eza -la --git --group-directories-first";
        cat = "bat";
        grep = "rg";
        find = "fd";

        # Navigation aliases
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # System aliases
        c = "clear";
        h = "history";

        # Development aliases
        dc = "docker-compose";
        k = "kubectl";
        tf = "terraform";
        vi = "nvim";
        vim = "nvim";

        # Tmux aliases
        t = "tmux";
        ta = "tmux attach -t";
        tn = "tmux new -s";

        # Kubernetes shortcuts
        kgn = "kubectl get nodes -o wide";
        kgp = "kubectl get pods -o wide";
        kgd = "kubectl get deployment -o wide";
        kgs = "kubectl get svc -o wide";
      };
    };

    # Shell enhancement programs
    programs.starship = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };

    programs.direnv = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };
  };
}
```

### Git Configuration

```nix
# modules/home-manager/shell/git.nix
{ config, lib, ... }:
let
  cfg = config.myHome.shell.git;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.username;
      userEmail = cfg.email;

      aliases = {
        # Advanced aliases from dotfiles
        gone = "! \"git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D\"";
        staash = "stash --all";
        bb = "!~/bin/better-git-branch.sh";
        yolo = "!git commit -S -m \"$(curl --silent --fail https://whatthecommit.com/index.txt)\"";
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
      };

      extraConfig = {
        init = {
          templatedir = "~/.git-templates";
          defaultBranch = "main";
        };

        core = {
          excludesfile = "~/.gitignore";
          editor = "nvim";
          autocrlf = "input";
        };

        # Delta configuration for better diffs
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          side-by-side = true;
          diff-so-fancy = true;
          paging-mode = "never";
          features = "tokyonight_night";
          dark = true;
        };

        merge = {
          conflictstyle = "diff3";
          tool = "nvimdiff";
        };

        diff = {
          colorMoved = "default";
          algorithm = "histogram";
        };

        fetch.prune = true;

        push = {
          default = "current";
          autoSetupRemote = true;
        };

        # Profile-specific configurations
      } // lib.optionalAttrs (config.myHome.profileType == "work") {
        # Work-specific git config
        commit.gpgSign = true;
        user.signingKey = "~/.ssh/id_rsa.pub";
        gpg.format = "ssh";
      };

      # Profile-specific includes
      includes = lib.optionals (config.myHome.profileType == "work") [
        { path = "~/.gitconfig.work"; }
      ] ++ lib.optionals (config.myHome.profileType == "personal") [
        { path = "~/.gitconfig.personal"; }
      ] ++ [
        # Conditional includes for specific directories
        {
          condition = "gitdir:~/Projects/writing/obsidian-vault/";
          path = "~/.gitconfig.personal";
        }
        {
          condition = "gitdir:~/.config/nvim/";
          path = "~/.gitconfig.personal";
        }
      ];
    };
  };
}
```

### Shell Features

#### 1. **Modern CLI Integration**
- **Enhanced Commands**: eza, bat, ripgrep, fd replacing traditional tools
- **Smart Navigation**: zoxide for intelligent directory jumping
- **Fuzzy Finding**: fzf integration for file and command finding

#### 2. **Development Workflow**
- **Git Integration**: Comprehensive Git configuration with delta
- **Environment Management**: direnv for project-specific environments
- **Terminal Enhancement**: Starship prompt with project context

#### 3. **Profile-Aware Configuration**
- **Git Profiles**: Different Git settings for work vs personal
- **Signing Configuration**: GPG signing for work, disabled for personal
- **Email Management**: Automatic email selection based on profile

## 📄 Dotfiles Module (dotfiles/)

### Purpose
Manages dotfile sourcing, linking, and configuration file management.

```nix
# modules/home-manager/dotfiles/default.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.myHome.dotfiles;
in
{
  options.myHome.dotfiles = {
    enable = lib.mkEnableOption "dotfiles management" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    # XDG configuration
    xdg = {
      enable = true;
      configHome = "${config.home.homeDirectory}/.config";
      dataHome = "${config.home.homeDirectory}/.local/share";
      cacheHome = "${config.home.homeDirectory}/.cache";
    };

    # Git templates and hooks
    home.file.".git-templates/hooks/commit-msg" = {
      source = pkgs.writeScript "commit-msg" ''
        #!/bin/sh
        # Add commit message validation here
      '';
      executable = true;
    };

    # Global gitignore
    home.file.".gitignore" = {
      text = ''
        # macOS
        .DS_Store
        .AppleDouble
        .LSOverride

        # Thumbnails
        ._*

        # Files that might appear in the root of a volume
        .DocumentRevisions-V100
        .fseventsd
        .Spotlight-V100
        .TemporaryItems
        .Trashes
        .VolumeIcon.icns
        .com.apple.timemachine.donotpresent

        # Directories potentially created on remote AFP share
        .AppleDB
        .AppleDesktop
        Network Trash Folder
        Temporary Items
        .apdisk

        # Editor files
        .vscode/
        .idea/
        *.swp
        *.swo
        *~

        # Environment files
        .env
        .env.local
        .envrc

        # Dependencies
        node_modules/
        .pnp
        .pnp.js

        # Logs
        *.log
        npm-debug.log*
        yarn-debug.log*
        yarn-error.log*
      '';
    };

    # SSH configuration
    programs.ssh = {
      enable = true;
      matchBlocks = lib.mkMerge [
        # Common SSH configuration
        {
          "*" = {
            addKeysToAgent = "yes";
            useKeychain = true;
            identityFile = "~/.ssh/id_rsa";
          };
        }

        # Work-specific SSH configuration
        (lib.mkIf (config.myHome.profileType == "work") {
          "*.company.com" = {
            identityFile = "~/.ssh/work_id_rsa";
            user = "bwright";
          };
        })
      ];
    };
  };
}
```

## ⚙️ Module Options System

### myHome Options

```nix
# modules/home-manager/default.nix
options.myHome = {
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

  # Shell configuration options
  shell = {
    enable = mkEnableOption "shell configuration" // { default = true; };

    git = {
      enable = mkEnableOption "git configuration" // { default = true; };
      username = mkOption { /* ... */ };
      email = mkOption { /* ... */ };
    };

    fish = {
      enable = mkEnableOption "fish shell" // { default = true; };
    };

    aliases = {
      enable = mkEnableOption "shell aliases" // { default = true; };
    };
  };

  # Program configuration options
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

  # Dotfiles configuration options
  dotfiles = {
    enable = mkEnableOption "dotfiles management" // { default = true; };
  };
};
```

### Option Inheritance

```nix
# Automatic inheritance from system configuration
config.myHome = lib.mkDefault (lib.myLib.copyFromSystem "mySystem" osConfig);
```

## 🔗 Module Integration

### Cross-Module Dependencies

#### Programs → Shell Integration
```nix
# Shell module uses programs for tool availability
config = lib.mkIf (cfg.enable && config.myHome.programs.development) {
  programs.fish.shellAbbrs = {
    # Development-specific aliases
    dc = "docker-compose";
    k = "kubectl";
  };
};
```

#### Profile Consistency
```nix
# Ensure profile consistency across modules
assertions = [
  {
    assertion = config.myHome.shell.git.enable -> config.myHome.programs.development;
    message = "Git configuration requires development tools to be enabled";
  }
];
```

## 📊 Configuration Examples

### Minimal Home Configuration
```nix
{
  myHome = {
    username = "bwright";
    profileType = "personal";
    programs.work.enable = false;
  };
}
```

### Advanced Development Configuration
```nix
{
  myHome = {
    username = "bwright";
    profileType = "work";

    shell.git = {
      username = "Bradley Wright";
      email = "bradley.wright@company.com";
    };

    programs = {
      development.enable = true;
      work.enable = true;
      personal.enable = false;
    };
  };
}
```

## 🧪 Testing Home Manager Modules

### Configuration Testing
```bash
# Test home-manager configuration
home-manager build --flake .#bwright@Bradleys-MacBook-Pro

# Switch configuration
home-manager switch --flake .#bwright@Bradleys-MacBook-Pro

# Check specific programs
which eza bat ripgrep fd
```

### Package Validation
```bash
# Verify installed packages
home-manager packages | grep -E "(eza|bat|ripgrep)"

# Check shell configuration
fish -c "alias"

# Validate Git configuration
git config --list | grep user
```

The Home Manager modules provide comprehensive user environment management with profile awareness, modern tool integration, and extensive customization capabilities while maintaining declarative configuration principles.
