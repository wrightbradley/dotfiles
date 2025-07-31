# Documentation for Phase 1.2 and Beyond

## 🔍 SHA Hash Requirements for External Repositories

The following external repositories need SHA hashes calculated for reproducible builds:

### External Repos from external-repos.nix:
```nix
# These need actual SHA256 hashes calculated:
"nvim-config" = {
  url = "https://github.com/wrightbradley/nvim-config";
  # SHA required: nix-prefetch-url --unpack https://github.com/wrightbradley/nvim-config/archive/main.tar.gz
};

"tokyonight-gtk-theme" = {
  url = "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme";
  # SHA required: nix-prefetch-url --unpack https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/master.tar.gz
};

"aerospace-config" = {
  url = "https://github.com/wrightbradley/aerospace-config";
  # SHA required: Check if this repo exists first
};
```

### Commands to Calculate SHA Hashes:
```bash
# For each external repo, run:
nix-prefetch-url --unpack https://github.com/USER/REPO/archive/BRANCH.tar.gz

# Example:
nix-prefetch-url --unpack https://github.com/wrightbradley/nvim-config/archive/main.tar.gz
```

## 🧪 Testing and Validation Commands

### Phase 1.2 Package Validation:
```bash
# Check flake syntax
nix flake check

# Build configuration without applying
darwin-rebuild build --flake .#Bradleys-MacBook-Pro

# Test home-manager separately
home-manager build --flake .#bwright@Bradleys-MacBook-Pro

# Check for missing packages
nix-env -qaP | grep -i PACKAGE_NAME
```

### Phase 2 GUI Application Testing:
```bash
# Test homebrew integration
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro
brew list --cask
mas list

# Verify applications launch
open -a "Visual Studio Code"
open -a "Slack"
```

## 🔧 Development Workflow

### Testing Changes:
```bash
# Enter development shell
nix develop

# Format Nix files
nixfmt **/*.nix

# Quick syntax check
nix flake check --no-build

# Test specific module
darwin-rebuild build --flake .#Bradleys-MacBook-Pro --show-trace
```

### Profile Switching:
```bash
# Switch to work profile
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro

# Switch to personal profile
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro-personal
```

## 🚨 Known Issues and Workarounds

### 1. Missing Packages in nixpkgs
Some packages from the original Homebrew setup may not be available in nixpkgs:
- `kubectx` -> Use `kubectl-ctx` or install via homebrew fallback
- Some vendor-specific tools may need homebrew

### 2. Profile-Specific Secrets
Work aliases and secrets currently handled via GPG encryption in chezmoi need migration:
- Option A: Manual migration to sops-nix (Phase 4)
- Option B: Temporary manual setup during Phase 2-3

### 3. External Repository Management
- Need to verify all external repos exist and are accessible
- SHA hashes must be calculated for reproducible builds
- Some repos may need to be forked if original is unavailable

## 📋 Phase 1.2 Validation Checklist

- [ ] Calculate SHA hashes for external repositories
- [ ] Run `nix flake check` successfully
- [ ] Build darwin configuration without errors
- [ ] Build home-manager configuration without errors
- [ ] Verify all critical packages are available
- [ ] Identify packages requiring homebrew fallback
- [ ] Test profile switching mechanism
- [ ] Document any missing functionality

## 🔄 Next Phase Preparation

### Phase 2 Readiness:
- [ ] Homebrew cask list validated
- [ ] Mac App Store app IDs confirmed
- [ ] GUI application preferences documented

### Phase 3 Readiness:
- [ ] Tmux configuration analysis complete
- [ ] Shell completion requirements documented
- [ ] External repo SHA hashes calculated

### Phase 4 Readiness:
- [ ] sops-nix setup planned
- [ ] GPG-encrypted files inventoried
- [ ] Secret migration strategy defined
